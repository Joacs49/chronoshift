extends Node

var current_spawn_point = null

func set_current_spawn_point(path: NodePath) -> void:
	current_spawn_point = path

func get_current_spawn_point():
	return current_spawn_point
