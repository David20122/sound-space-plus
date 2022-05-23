extends CheckBox

func _pressed(): if pressed != SSP.play_hit_snd: SSP.play_hit_snd = pressed
func _ready(): pressed = SSP.play_hit_snd
