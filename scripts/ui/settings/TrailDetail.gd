extends SpinBox

func upd():
	Rhythia.trail_detail = value

func _process(_d):
	if value != Rhythia.trail_detail: upd()

func _ready():
	value = Rhythia.trail_detail
	connect("changed",self,"upd")
