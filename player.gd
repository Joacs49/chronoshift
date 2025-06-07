extends CharacterBody2D

var tamano_pantalla
@export var velocidad_jugador = 400

func _ready() -> void:
	tamano_pantalla = get_viewport_rect().size
	show()  # Asegura que esté visible

func _process(_delta: float) -> void:
	var direccion = Vector2.ZERO
	
	if Input.is_action_pressed("mover_derecha"):
		direccion.x += 1
	if Input.is_action_pressed("mover_izquierda"):
		direccion.x -= 1
	if Input.is_action_pressed("mover_arriba"):
		direccion.y -= 1
	if Input.is_action_pressed("mover_abajo"):
		direccion.y += 1

	if direccion.length() > 0:
		direccion = direccion.normalized()
		velocity = direccion * velocidad_jugador
		_play_animacion(direccion)
	else:
		velocity = Vector2.ZERO
		$AnimatedSprite2D.stop()

	move_and_slide()

func _play_animacion(direccion: Vector2) -> void:
	if direccion.y > 0:
		$AnimatedSprite2D.play("Vox-down")
	elif direccion.y < 0:
		$AnimatedSprite2D.play("Vox-up")
	elif direccion.x > 0:
		$AnimatedSprite2D.play("Vox-left")
	elif direccion.x < 0:
		$AnimatedSprite2D.play("Vox-right")
