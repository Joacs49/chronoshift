extends Node

var current_spawn_point = null  # No especificamos el tipo

func set_current_spawn_point(path: NodePath) -> void:
	current_spawn_point = path
