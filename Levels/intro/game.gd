extends Node

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Vox"):
		SceneSwitcher.change_scene_with_transition("res://scenes/Nivel1.tscn", "fade")
