extends Control

func _on_bt_out_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/menu/Menu.tscn")

func _on_check_button_toggled(pressed: bool) -> void:
	if pressed:
		AudioController.play_music()
	else:
		AudioController.stop_music()
