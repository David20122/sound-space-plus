extends Control

func _ready():
	$dya.play()

func _on_dya_finished():
	get_tree().quit()
