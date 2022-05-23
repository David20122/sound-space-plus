extends CheckBox

func _pressed(): if pressed != SSP.play_miss_snd: SSP.play_miss_snd = pressed
func _ready(): pressed = SSP.play_miss_snd
