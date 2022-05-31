extends CheckBox

func _process(_d):
	if pressed != SSP.mod_sudden_death:
		SSP.mod_sudden_death = pressed

func upd(): pressed = SSP.mod_sudden_death

func _ready():
	upd()
	SSP.connect("mods_changed",self,"upd")
