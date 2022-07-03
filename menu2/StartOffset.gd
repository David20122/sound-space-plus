extends SpinBox

func upd():
	SSP.start_offset = value * 1000

func _process(_d):
	if value != SSP.start_offset / 1000: upd()

func _ready():
	value = SSP.start_offset / 1000
	connect("changed",self,"upd")
