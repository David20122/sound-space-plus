extends Label

func upd():
	text = "C (%.0f%%)" % (Globals.speed_multi[Globals.SPEED_CUSTOM] * 100)

func _ready():
	upd()
	SSP.connect("mods_changed",self,"upd")
	SSP.connect("speed_mod_changed",self,"upd")
