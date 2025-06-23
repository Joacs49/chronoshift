extends Node

var transition

func _ready():
	transition = preload("res://transiciones/transition.tscn").instantiate()
	get_tree().root.call_deferred("add_child", transition)

func change_scene_with_transition(scene_path: String, effect: String = "fade") -> void:
	transition.play(effect)
	await transition.animation_finished
	get_tree().change_scene_to_file(scene_path)
