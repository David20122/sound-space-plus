extends SpinBox

func upd():
	Rhythia.approach_rate = value

func _process(_d):
	if value != Rhythia.approach_rate: upd()

func _ready():
	value = Rhythia.approach_rate
	connect("changed",self,"upd")
