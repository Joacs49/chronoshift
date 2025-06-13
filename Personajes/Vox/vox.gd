extends CharacterBody2D

var tamano_pantalla
@export var velocidad_jugador = 200

func _ready() -> void:
	tamano_pantalla = get_viewport_rect().size
	show()
	#Global.jugador = self
	
func _physics_process(delta: float) -> void:
	var direccion = Vector2.ZERO

	# Movimiento en ambas direcciones
	if Input.is_action_pressed("mover_derecha"):
		direccion_x += 1
	if Input.is_action_pressed("mover_izquierda"):
		direccion.x -= 1
	if Input.is_action_pressed("mover_abajo"):
		direccion.y += 1
	if Input.is_action_pressed("mover_arriba"):
		direccion.y -= 1

	# Normalizar dirección para evitar movimiento diagonal más rápido
	if direccion != Vector2.ZERO:
		direccion = direccion.normalized()

	velocity = direccion * velocidad_jugador

	# Reproducir animaciones según dirección
	if direccion != Vector2.ZERO:
		_play_animacion(direccion)
	else:
		$AnimatedSprite2D.stop()

	# Aplicar movimiento con física
	move_and_slide()

func _play_animacion(direccion: Vector2) -> void:
	if direccion.x > 0:
		$AnimatedSprite2D.play("Vox-left")
	elif direccion.x < 0:
		$AnimatedSprite2D.play("Vox-right")
	elif direccion.y < 0:
		$AnimatedSprite2D.play("Vox-up")
	elif direccion.y > 0:
		$AnimatedSprite2D.play("Vox-down")
