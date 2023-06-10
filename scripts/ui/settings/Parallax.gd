extends SpinBox

func upd():
	SSP.parallax = value

func _process(_d):
	if value != SSP.parallax: upd()
	
func _ready():
	value = SSP.parallax
	connect("changed",self,"upd")
