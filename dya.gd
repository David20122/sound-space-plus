extends Control

func _ready():
	# Get the video using
	# git lfs fetch --all
	# git lfs pull
	$dya.play()

func _on_dya_finished():
	get_tree().quit()
