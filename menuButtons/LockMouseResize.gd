extends SpinBox

func upd():
	SSP.absolute_scale = value

func _process(_d):
	if value != SSP.absolute_scale: upd()
	
func _ready():
	value = SSP.absolute_scale
	connect("changed",self,"upd")
