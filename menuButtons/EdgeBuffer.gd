extends SpinBox

func upd():
	SSP.edge_drift = value

func _process(_d):
	if value != SSP.edge_drift: upd()

func _ready():
	value = SSP.edge_drift
	connect("changed",self,"upd")
