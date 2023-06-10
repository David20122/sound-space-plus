extends CheckBox

func _process(_d):
	if pressed != SSP.mod_flashlight:
		SSP.mod_flashlight = pressed

func upd(): pressed = SSP.mod_flashlight

func _ready():
	upd()
	SSP.connect("mods_changed",self,"upd")
