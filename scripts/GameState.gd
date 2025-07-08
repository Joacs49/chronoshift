extends Node

signal player_caught

var current_spawn_point = null

func notify_player_caught():
	emit_signal("player_caught")

func set_current_spawn_point(path: NodePath) -> void:
	current_spawn_point = path

func get_current_spawn_point():
	return current_spawn_point

func reset_spawn_point():
	current_spawn_point = null
