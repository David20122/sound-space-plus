extends SpinBox

func upd():
	Rhythia.edge_drift = value

func _process(_d):
	if value != Rhythia.edge_drift: upd()

func _ready():
	value = Rhythia.edge_drift
	connect("changed",self,"upd")
