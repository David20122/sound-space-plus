extends SpinBox

func upd():
	Rhythia.bloom = value

func _process(_d):
	if value != Rhythia.bloom: upd()

func _ready():
	value = Rhythia.bloom
	connect("changed",self,"upd")
