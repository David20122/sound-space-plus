extends CheckBox

func _process(_d):
	if pressed != SSP.invert_mouse:
		SSP.invert_mouse = pressed

func upd(): pressed = SSP.invert_mouse

func _ready():
	upd()
	SSP.connect("mods_changed",self,"upd")
