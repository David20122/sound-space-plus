extends SpinBox

func upd():
	SSP.fov = value

func _process(_d):
	if value != SSP.fov: upd()
	
func _ready():
	value = SSP.fov
	connect("changed",self,"upd")
