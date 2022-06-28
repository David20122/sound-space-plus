extends CheckBox

export(String) var target

func upd():
	pressed = SSP.get(target)
	
func _pressed():
	if pressed != SSP.get(target):
		SSP.set(target,pressed)

func _ready():
	pressed = SSP.get(target)
