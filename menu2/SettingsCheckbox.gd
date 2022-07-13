extends CheckBox

export(String) var target

func upd():
#	print('scb "%s"' % name)
	pressed = SSP.get(target)
	
func _pressed():
	var a = OS.get_ticks_usec()
#	print('scb "%s" press' % name)
	if pressed != SSP.get(target):
		SSP.set(target,pressed)
#	print('scb "%s" press done, took %s usec' % [name,Globals.comma_sep(OS.get_ticks_usec() - a)])

func _ready():
	upd()
