extends SpinBox

func upd():
	Globals.speed_multi[7] = value / 100

func _process(_d):
	if value != Globals.speed_multi[7] * 100: upd()

func _ready():
	value = Globals.speed_multi[7] * 100
	connect("changed",self,"upd")
