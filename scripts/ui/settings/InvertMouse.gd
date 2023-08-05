extends CheckBox

func _process(_d):
	if pressed != Rhythia.invert_mouse:
		Rhythia.invert_mouse = pressed

func upd(): pressed = Rhythia.invert_mouse

func _ready():
	upd()
	Rhythia.connect("mods_changed",self,"upd")
