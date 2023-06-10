extends SpinBox

func upd():
	SSP.approach_rate = value

func _process(_d):
	if value != SSP.approach_rate: upd()

func _ready():
	value = SSP.approach_rate
	connect("changed",self,"upd")
