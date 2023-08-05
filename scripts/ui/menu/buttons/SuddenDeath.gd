extends CheckBox

func _process(_d):
	if pressed != Rhythia.mod_sudden_death:
		Rhythia.mod_sudden_death = pressed

func upd(): pressed = Rhythia.mod_sudden_death

func _ready():
	upd()
	Rhythia.connect("mods_changed",self,"upd")
