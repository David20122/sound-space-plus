extends SpinBox

func upd():
	Rhythia.spawn_distance = value

func _process(_d):
	if value != Rhythia.spawn_distance: upd()

func _ready():
	connect("changed",self,"upd")
	value = Rhythia.spawn_distance
