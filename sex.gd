extends Control

func _ready():
	$AudioStreamPlayer.play()

func _on_AudioStreamPlayer_finished():
	get_tree().quit()
