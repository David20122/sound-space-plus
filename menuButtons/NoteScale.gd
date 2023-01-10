extends SpinBox

func upd():
	SSP.note_size = value

func _process(_d):
	if value != SSP.note_size: upd()

func _ready():
	value = SSP.note_size
	connect("changed",self,"upd")
