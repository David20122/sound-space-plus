extends CheckBox

func upd():
	pressed = SSP.show_hit_effect
	
func _pressed():
	if pressed != SSP.show_hit_effect:
		SSP.show_hit_effect = pressed

func _ready():
	pressed = SSP.show_hit_effect
