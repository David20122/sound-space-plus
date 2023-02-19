extends Control

func _ready():
	$Label.text = "Sound Space Plus [%s]" % ProjectSettings.get_setting_with_override("application/config/version")
