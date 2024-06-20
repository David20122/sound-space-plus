extends Control

func _ready():
    # Github file limiter sucks, make this feature work by adding the video found in the link below:
    # https://drive.google.com/file/d/1TPrnleFUK8yzb_J6JZE50RIIdfcHoU9i/view?usp=sharing
	$dya.play()

func _on_dya_finished():
	get_tree().quit()
