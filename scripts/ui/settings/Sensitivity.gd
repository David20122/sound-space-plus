extends SpinBox

func upd():
	Rhythia.sensitivity = value

func _process(_d):
	if value != Rhythia.sensitivity: upd()
	
func _ready():
	value = Rhythia.sensitivity
	connect("changed",self,"upd")
