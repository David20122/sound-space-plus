extends SpinBox

func upd():
	SSP.music_offset = value

func _process(_d):
	if value != SSP.music_offset: upd()

func _ready():
	connect("changed",self,"upd")
	value = SSP.music_offset
