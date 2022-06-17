extends CheckBox

func upd():
	pressed = SSP.display_true_combo
	
func _pressed():
	if pressed != SSP.display_true_combo:
		SSP.display_true_combo = pressed

func _ready():
	pressed = SSP.display_true_combo
