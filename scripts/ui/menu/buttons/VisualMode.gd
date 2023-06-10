extends CheckBox

func _process(_d):
	if pressed != SSP.visual_mode:
		SSP.visual_mode = pressed

func upd(): pressed = SSP.visual_mode

func _ready():
	upd()
	SSP.connect("mods_changed",self,"upd")
