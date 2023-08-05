extends SpinBox

func upd():
	Rhythia.cursor_scale = value

func _process(_d):
	if value != Rhythia.cursor_scale: upd()

func _ready():
	value = Rhythia.cursor_scale
	connect("changed",self,"upd")
