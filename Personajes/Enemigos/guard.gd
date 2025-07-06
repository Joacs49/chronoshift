@tool
class_name Guard extends CharacterBody2D
#signal player_detected(player: Node2D)

enum State {
	PATROLLING,
	DETECTING,
	ALERTED,
	INVESTIGATING,
	RETURNING,
}

const DEFAULT_SPRITE_FRAMES = preload("res://Personajes/Enemigos/enemigo-1/template_guard_enemy.tres")
const LOOK_AT_TURN_SPEED: float = 10.0

@export_category("Appearance")
@export var sprite_frames: SpriteFrames = DEFAULT_SPRITE_FRAMES:
	set(new_value):
		sprite_frames = new_value
		if animated_sprite_2d:
			animated_sprite_2d.sprite_frames = sprite_frames
		update_configuration_warnings()

@export_category("Patrol")
@warning_ignore("unused_private_class_variable")
@export_tool_button("Add/Edit Patrol Path") var _edit_patrol_path: Callable = edit_patrol_path
@export var patrol_path: Path2D:
	set(new_value):
		patrol_path = new_value
		if Engine.is_editor_hint():
			queue_redraw()

@export_range(0, 5, 0.1, "or_greater", "suffix:s") var wait_time: float = 1.0
@export_range(20, 300, 5, "or_greater", "or_less", "suffix:m/s") var move_speed: float = 100.0

@export_category("Player Detection")
@export var player_instantly_detected_on_sight: bool = false
@export_range(0.1, 5, 0.1, "or_greater", "suffix:s") var time_to_detect_player: float = 1.0
@export_range(0.1, 5, 0.1, "or_greater", "or_less") var detection_area_scale: float = 1.0:
	set(new_value):
		detection_area_scale = new_value
		if detection_area:
			detection_area.scale = Vector2.ONE * detection_area_scale

@export_category("Debug")
@export var move_while_in_editor: bool = false
@export var show_debug_info: bool = false

var previous_patrol_point_idx: int = -1
var current_patrol_point_idx: int = 0
var last_seen_position: Vector2
var breadcrumbs: Array[Vector2] = []
var state: State = State.PATROLLING:
	set = _change_state

@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var detection_area: Area2D = %DetectionArea
@onready var player_awareness: TextureProgressBar = %PlayerAwareness
@onready var instant_detection_area: Area2D = %InstantDetectionArea
@onready var sight_ray_cast: RayCast2D = %SightRayCast
@onready var debug_info: Label = %DebugInfo
@onready var guard_movement: GuardMovement = %GuardMovement
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray

	if not sprite_frames:
		warnings.push_back("sprite_frames must be set.")

	for required_animation: StringName in [&"alerted", &"idle", &"walk"]:
		if sprite_frames and not sprite_frames.has_animation(required_animation):
			warnings.push_back("sprite_frames is missing the following animation: %s" % required_animation)

	return warnings


func _ready() -> void:
	if Engine.is_editor_hint():
		var selection_changed: Signal = _editor_interface().get_selection().selection_changed
		if not selection_changed.is_connected(self.queue_redraw):
			selection_changed.connect(self.queue_redraw)
	else:
		if player_awareness:
			player_awareness.max_value = time_to_detect_player
			player_awareness.value = 0.0

	if animated_sprite_2d:
		animated_sprite_2d.sprite_frames = sprite_frames

	if detection_area:
		detection_area.scale = Vector2.ONE * detection_area_scale

	if patrol_path:
		global_position = _patrol_point_position(0)

	guard_movement.destination_reached.connect(self._on_destination_reached)
	guard_movement.still_time_finished.connect(self._on_still_time_finished)
	guard_movement.path_blocked.connect(self._on_path_blocked)


func _process(delta: float) -> void:
	_update_debug_info()

	if Engine.is_editor_hint() and not move_while_in_editor:
		return

	_process_state()
	guard_movement.move()
	_update_direction(delta)

	var player_in_sight: Node2D = _player_in_sight()
	_detect_player(player_in_sight)
	_update_player_awareness(player_in_sight, delta)
	_update_animation()


func _process_state() -> void:
	match state:
		State.PATROLLING:
			if patrol_path:
				var target_position: Vector2 = _patrol_point_position(current_patrol_point_idx)
				guard_movement.set_destination(target_position)
			else:
				guard_movement.stop_moving()
		State.INVESTIGATING:
			guard_movement.set_destination(last_seen_position)
		State.DETECTING:
			guard_movement.stop_moving()
			if not _player_in_sight():
				_change_state(State.INVESTIGATING)
		State.RETURNING:
			if not breadcrumbs.is_empty():
				var target_position: Vector2 = breadcrumbs.back()
				guard_movement.set_destination(target_position)
			else:
				_change_state(State.PATROLLING)
		State.ALERTED:
			guard_movement.stop_moving()


func _update_direction(delta: float) -> void:
	if velocity.is_zero_approx():
		return

	var target_angle: float = velocity.angle()
	detection_area.rotation = rotate_toward(detection_area.rotation, target_angle, delta * LOOK_AT_TURN_SPEED)

	if sprite and not is_zero_approx(velocity.x):
		sprite.flip_h = velocity.x < 0


func _detect_player(player_in_sight: Node2D) -> void:
	if not player_in_sight:
		return

	last_seen_position = player_in_sight.global_position

	if (
		instant_detection_area.has_overlapping_bodies()
		or player_awareness.ratio >= 1.0
		or player_instantly_detected_on_sight
	):
		_change_state(State.ALERTED)
	else:
		_change_state(State.DETECTING)


func _update_player_awareness(player_in_sight: Node2D, delta: float) -> void:
	if State.ALERTED == state:
		player_awareness.ratio = 1.0
		player_awareness.tint_progress = Color.RED
	else:
		player_awareness.value = move_toward(
			player_awareness.value, player_awareness.max_value if player_in_sight else 0.0, delta
		)

	player_awareness.visible = player_awareness.ratio > 0.0
	player_awareness.modulate.a = clamp(player_awareness.ratio, 0.5, 1.0)


func _update_animation() -> void:
	if state == State.ALERTED and animation_player.current_animation == &"alerted":
		return

	if velocity.is_zero_approx():
		animation_player.stop()
		sprite.play(&"idle")
	else:
		animation_player.play(&"walk")


func _update_debug_info() -> void:
	debug_info.visible = show_debug_info
	if not debug_info.visible:
		return
	debug_info.text = ""
	debug_property("position")
	debug_value("state", State.keys()[state])
	debug_property("previous_patrol_point_idx")
	debug_property("current_patrol_point_idx")
	debug_value("time left", "%.2f" % guard_movement.still_time_left_in_seconds)
	debug_value("target point", guard_movement.destination)


func debug_property(property_name: String) -> void:
	debug_value(property_name, get(property_name))


func debug_value(value_name: String, value: Variant) -> void:
	debug_info.text += "%s: %s\n" % [value_name, value]


func _on_destination_reached() -> void:
	match state:
		State.PATROLLING:
			guard_movement.wait_seconds(wait_time)
			_advance_target_patrol_point()
		State.INVESTIGATING:
			guard_movement.wait_seconds(wait_time)
		State.RETURNING:
			breadcrumbs.pop_back()


func _on_still_time_finished() -> void:
	match state:
		State.INVESTIGATING:
			_change_state(State.RETURNING)


func _on_path_blocked() -> void:
	match state:
		State.PATROLLING:
			guard_movement.wait_seconds(wait_time)
			if previous_patrol_point_idx > -1:
				var new_patrol_point: int = previous_patrol_point_idx
				previous_patrol_point_idx = current_patrol_point_idx
				current_patrol_point_idx = new_patrol_point
		State.INVESTIGATING:
			_change_state(State.RETURNING)
		State.RETURNING:
			if not breadcrumbs.is_empty():
				breadcrumbs.pop_back()


func _change_state(next_state: State) -> void:
	if next_state == state:
		return
	state = next_state


func _advance_target_patrol_point() -> void:
	if not patrol_path or not patrol_path.curve or _amount_of_patrol_points() < 2:
		return

	var new_patrol_point_idx: int

	if _is_patrol_path_closed():
		new_patrol_point_idx = (current_patrol_point_idx + 1) % (_amount_of_patrol_points() - 1)
	else:
		var at_last_point: bool = current_patrol_point_idx == (_amount_of_patrol_points() - 1)
		var at_first_point: bool = current_patrol_point_idx == 0
		var going_backwards_in_path: bool = previous_patrol_point_idx > current_patrol_point_idx

		if at_last_point:
			new_patrol_point_idx = current_patrol_point_idx - 1
		elif at_first_point:
			new_patrol_point_idx = current_patrol_point_idx + 1
		elif going_backwards_in_path:
			new_patrol_point_idx = current_patrol_point_idx - 1
		else:
			new_patrol_point_idx = current_patrol_point_idx + 1

	previous_patrol_point_idx = current_patrol_point_idx
	current_patrol_point_idx = new_patrol_point_idx


func _is_sight_to_point_blocked(point_position: Vector2) -> bool:
	sight_ray_cast.target_position = sight_ray_cast.to_local(point_position)
	sight_ray_cast.force_raycast_update()
	return sight_ray_cast.is_colliding()


func _player_in_sight() -> Node2D:
	if instant_detection_area.has_overlapping_bodies():
		return instant_detection_area.get_overlapping_bodies().front()

	if not detection_area.has_overlapping_bodies():
		return null

	var player: Node2D = detection_area.get_overlapping_bodies().front()

	if _is_sight_to_point_blocked(player.global_position):
		return null

	return player


func _patrol_point_position(point_idx: int) -> Vector2:
	var local_point_position: Vector2 = patrol_path.curve.get_point_position(point_idx)
	return patrol_path.to_global(local_point_position)


func _amount_of_patrol_points() -> int:
	return patrol_path.curve.point_count


func _is_patrol_path_closed() -> bool:
	if not patrol_path:
		return false

	var curve: Curve2D = patrol_path.curve
	if curve.point_count < 3:
		return false

	var first_point_position: Vector2 = curve.get_point_position(0)
	var last_point_position: Vector2 = curve.get_point_position(curve.point_count - 1)

	return first_point_position.is_equal_approx(last_point_position)


func _reset() -> void:
	previous_patrol_point_idx = -1
	current_patrol_point_idx = 0
	velocity = Vector2.ZERO
	if patrol_path:
		global_position = _patrol_point_position(0)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_EDITOR_PRE_SAVE:
			_reset()


func _editor_interface() -> Node:
	return Engine.get_singleton("EditorInterface")


func edit_patrol_path() -> void:
	if not Engine.is_editor_hint():
		return

	var editor_interface := _editor_interface()

	if patrol_path:
		editor_interface.edit_node.call_deferred(patrol_path)
	else:
		var new_patrol_path: Path2D = Path2D.new()
		patrol_path = new_patrol_path
		get_parent().add_child(patrol_path)
		patrol_path.owner = owner
		patrol_path.global_position = global_position
		var patrol_path_curve: Curve2D = Curve2D.new()
		patrol_path.curve = patrol_path_curve
		patrol_path.name = "%s-PatrolPath" % name
		patrol_path_curve.add_point(Vector2.ZERO)
		patrol_path_curve.add_point(Vector2.RIGHT * 150.0)
		editor_interface.edit_node.call_deferred(patrol_path)


func _draw() -> void:
	if Engine.is_editor_hint() and self in _editor_interface().get_selection().get_selected_nodes():
		var debug_color: Color = Color.RED
		var line_width: float = 5.0
		var point_size: float = 15.

		if patrol_path and patrol_path.curve:
			var curve: Curve2D = patrol_path.curve
			if curve.point_count > 1:
				for point_idx in curve.point_count - 1:
					draw_line(
						to_local(patrol_path.to_global(curve.get_point_position(point_idx))),
						to_local(patrol_path.to_global(curve.get_point_position(point_idx + 1))),
						debug_color,
						line_width,
						true
					)
			for point_idx in curve.point_count:
				draw_circle(
					to_local(patrol_path.to_global(curve.get_point_position(point_idx))),
					point_size,
					debug_color
				)
