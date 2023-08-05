extends SpinBox

func upd():
	Rhythia.hitwindow_ms = value

func _process(_d):
	if value != Rhythia.hitwindow_ms: upd()
	
func _ready():
	value = Rhythia.hitwindow_ms
	connect("changed",self,"upd")
