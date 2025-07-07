extends Area2D

@onready var spawn_point = $SpawnPoint

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		GameState.set_current_spawn_point(get_path_to(spawn_point))
