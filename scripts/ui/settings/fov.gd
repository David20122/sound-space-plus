extends SpinBox

func upd():
	Rhythia.fov = value

func _process(_d):
	if value != Rhythia.fov: upd()
	
func _ready():
	value = Rhythia.fov
	connect("changed",self,"upd")
