extends CanvasLayer

signal animation_finished

@onready var fade_rect = $FadeRect
@onready var animator = $AnimationPlayer

func play(effect: String = "fade") -> void:
	if animator.has_animation(effect):
		animator.play(effect)

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	emit_signal("animation_finished") # Replace with function body.
