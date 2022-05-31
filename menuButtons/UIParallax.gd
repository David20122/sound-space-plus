extends SpinBox

func upd():
	SSP.ui_parallax = value

func _process(_d):
	if value != SSP.ui_parallax: upd()
	
func _ready():
	value = SSP.ui_parallax
	connect("changed",self,"upd")
