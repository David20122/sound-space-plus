extends CheckBox

func upd():
	pressed = SSP.note_spawn_effect
	
func _pressed():
	if pressed != SSP.note_spawn_effect:
		SSP.note_spawn_effect = pressed

func _ready():
	pressed = SSP.note_spawn_effect
