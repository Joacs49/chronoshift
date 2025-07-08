extends Node

@onready var bg_music: AudioStreamPlayer = $bg_music

func _ready():
	play_music()

func play_music():
	bg_music.play()

func stop_music():
	bg_music.stop()
