extends Node

func _ready():
	GameState.reset_spawn_point()

func change_scene_with_transition(scene_path: String, effect: String = "fade") -> void:
	Transition.play(effect)  # fade out
	await Transition.animation_finished
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame  # Espera un frame para asegurar que la escena cargó
	Transition.play("fade_in")      # fade in
