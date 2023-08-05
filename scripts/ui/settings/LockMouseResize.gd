extends SpinBox

func upd():
	Rhythia.absolute_scale = value

func _process(_d):
	if value != Rhythia.absolute_scale: upd()
	
func _ready():
	value = Rhythia.absolute_scale
	connect("changed",self,"upd")
