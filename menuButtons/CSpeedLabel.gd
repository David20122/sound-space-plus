extends Label

func upd():
	text = "C (%.0f%%)" % (SSP.custom_speed * 100)

func _ready():
	upd()
	SSP.connect("mods_changed",self,"upd")
