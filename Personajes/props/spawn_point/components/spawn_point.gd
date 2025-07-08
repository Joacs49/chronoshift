extends Marker2D

func _ready():
	if Engine.is_editor_hint():
		return

	add_to_group("spawn")  # ← nuevo

	if GameState.current_spawn_point == get_tree().current_scene.get_path_to(self):
		move_player_to_self_position()

func move_player_to_self_position():
	var player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player):
		player.global_position = global_position
