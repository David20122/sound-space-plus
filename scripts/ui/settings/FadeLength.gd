extends SpinBox

func upd():
	Rhythia.fade_length = value / 100

func _process(_d):
	if value != Rhythia.fade_length * 100: upd()

func _ready():
	value = Rhythia.fade_length * 100
	connect("changed",self,"upd")
