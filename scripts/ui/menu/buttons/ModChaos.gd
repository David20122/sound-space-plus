extends CheckBox

func _process(_d):
	if pressed != Rhythia.mod_chaos:
		Rhythia.mod_chaos = pressed

func upd(): pressed = Rhythia.mod_chaos

func _ready():
	upd()
	Rhythia.connect("mods_changed",self,"upd")
