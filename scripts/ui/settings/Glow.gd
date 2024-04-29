extends SpinBox

func upd():
	Rhythia.glow = value

func _process(_d):
	if value != Rhythia.glow: upd()

func _ready():
	value = Rhythia.glow
	connect("changed",self,"upd")
