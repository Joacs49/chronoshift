extends CharacterBody2D

var tamano_pantalla
@export var velocidad_jugador = 200
var posicion_inicial: Vector2  # ← NUEVO

func _ready() -> void:
	posicion_inicial = global_position 
	tamano_pantalla = get_viewport_rect().size
	show()
	
func _physics_process(_delta):
	if Input.is_action_just_pressed("r"):  # tecla para test
		respawn()

	var direccion = Vector2.ZERO

	# Movimiento en ambas direcciones
	if Input.is_action_pressed("mover_derecha"):
		direccion.x += 1
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

# En el jugador
func respawn():
	var path = GameState.get_current_spawn_point()

	# Si ya hay un checkpoint activado, úsalo
	if path != null:
		var spawn = get_node_or_null(path)
		if spawn:
			global_position = spawn.global_position
		else:
			global_position = posicion_inicial
	else:
		global_position = posicion_inicial

	velocity = Vector2.ZERO
# ← para evitar moverse tras reaparecer
