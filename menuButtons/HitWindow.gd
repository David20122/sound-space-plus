extends SpinBox

func upd():
	SSP.hitwindow_ms = value

func _process(_d):
	if value != SSP.hitwindow_ms: upd()
	
func _ready():
	value = SSP.hitwindow_ms
	connect("changed",self,"upd")
