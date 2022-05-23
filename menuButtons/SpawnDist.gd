extends SpinBox

func upd():
	SSP.spawn_distance = value

func _process(_d):
	if value != SSP.spawn_distance: upd()

func _ready():
	connect("changed",self,"upd")
	value = SSP.spawn_distance
