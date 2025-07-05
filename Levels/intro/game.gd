extends Node

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Vox"):
		SceneSwitcher.change_scene_with_transition("res://Levels/nivel_1.tscn", "fade")
