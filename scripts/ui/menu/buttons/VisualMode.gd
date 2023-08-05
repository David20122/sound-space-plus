extends CheckBox

func _process(_d):
	if pressed != Rhythia.visual_mode:
		Rhythia.visual_mode = pressed

func upd(): pressed = Rhythia.visual_mode

func _ready():
	upd()
	Rhythia.connect("mods_changed",self,"upd")
