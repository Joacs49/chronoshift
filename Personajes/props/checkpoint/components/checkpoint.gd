extends Area2D

@onready var spawn_point = $SpawnPoint

func _on_body_entered(body: Node2D) -> void:
	print("🔍 Algo entró al checkpoint:", body.name, "| Grupos:", body.get_groups())

	if body.name == "Vox":
		GameState.set_current_spawn_point(spawn_point.get_path())
		print("✅ Checkpoint activado por:", body.name)
		print("📍 Guardado en GameState:", GameState.get_current_spawn_point())
	else:
		print("❌ No es el jugador. Ignorado.")
