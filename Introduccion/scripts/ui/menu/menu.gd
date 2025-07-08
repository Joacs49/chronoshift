extends Control

func _on_bt_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/intro/intro.tscn")

func _on_bt_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/options/Options.tscn")

func _on_bt_out_pressed() -> void:
	get_tree().quit()
