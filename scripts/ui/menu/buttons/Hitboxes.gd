extends Label

func upd():
	var txt = ""
	if SSP.note_hitbox_size == 1.140: txt += "Default hitboxes, "
	else: txt += "Hitboxes: %s, " % SSP.note_hitbox_size
	if SSP.hitwindow_ms == 55: txt += "default hitwindow"
	else: txt += "hitwindow: %s ms" % SSP.hitwindow_ms
	text = txt

func _ready():
	upd()
	SSP.connect("mods_changed",self,"upd")
