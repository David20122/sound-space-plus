extends SpinBox

func upd():
	Rhythia.parallax = value

func _process(_d):
	if value != Rhythia.parallax: upd()
	
func _ready():
	value = Rhythia.parallax
	connect("changed",self,"upd")
