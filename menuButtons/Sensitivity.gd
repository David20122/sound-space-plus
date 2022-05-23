extends SpinBox

func upd():
	SSP.sensitivity = value

func _process(_d):
	if value != SSP.sensitivity: upd()
	
func _ready():
	value = SSP.sensitivity
	connect("changed",self,"upd")
