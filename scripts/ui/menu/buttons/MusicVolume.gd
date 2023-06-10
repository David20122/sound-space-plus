extends SpinBox

func upd():
	SSP.music_volume_db = value

func _process(_d):
	if value != SSP.music_volume_db: upd()

func _ready():
	connect("changed",self,"upd")
	value = SSP.music_volume_db
