extends Control

func _ready():
	$Label.text = "Sound Space Plus [%s]" % ProjectSettings.get_setting("application/config/version")