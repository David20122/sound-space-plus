extends SpinBox

func upd():
	Rhythia.ui_parallax = value

func _process(_d):
	if value != Rhythia.ui_parallax: upd()
	
func _ready():
	value = Rhythia.ui_parallax
	connect("changed",self,"upd")
