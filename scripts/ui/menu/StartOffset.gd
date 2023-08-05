extends SpinBox

func upd():
	Rhythia.start_offset = value * 1000

func _process(_d):
	if value != Rhythia.start_offset / 1000: upd()

func _ready():
	value = Rhythia.start_offset / 1000
	connect("changed",self,"upd")
