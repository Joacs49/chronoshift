extends Area2D

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("🎉 Jugador llegó al final. Fin del juego.")
		get_tree().quit()  # ← Esta línea debe estar DENTRO de la función
