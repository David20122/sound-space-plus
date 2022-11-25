extends SpinBox

func upd():
	SSP.hitsync_offset = value

func _process(_d):
	if value != SSP.hitsync_offset: upd()

func _ready():
	connect("changed",self,"upd")
	value = SSP.hitsync_offset
