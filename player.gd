extends CharacterBody2D

var tamano_pantalla
@export var velocidad_jugador = 200
@export var fuerza_salto = -400
@export var gravedad = 900

func _ready() -> void:
	tamano_pantalla = get_viewport_rect().size
	show()

func _physics_process(delta: float) -> void:
	var direccion_x = 0

	# Movimiento lateral
	if Input.is_action_pressed("mover_derecha"):
		direccion_x += 1
	if Input.is_action_pressed("mover_izquierda"):
		direccion_x -= 1
	
	velocity.x = direccion_x * velocidad_jugador

	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravedad * delta
	else:
		# Salto
		if Input.is_action_just_pressed("saltar"):
			velocity.y = fuerza_salto

	# Reproducir animación
	if direccion_x != 0:
		_play_animacion(Vector2(direccion_x, 0))
	elif not is_on_floor():
		$AnimatedSprite2D.play("Vox-down")  # Puedes cambiar esto a una animación de salto si tienes
	else:
		$AnimatedSprite2D.stop()

	# Aplicar movimiento con física
	move_and_slide()

func _play_animacion(direccion: Vector2) -> void:
	if direccion.x > 0:
		$AnimatedSprite2D.play("Vox-left")
	elif direccion.x < 0:
		$AnimatedSprite2D.play("Vox-right")
