extends SpinBox

func upd():
	SSP.fade_length = value / 100

func _process(_d):
	if value != SSP.fade_length * 100: upd()

func _ready():
	value = SSP.fade_length * 100
	connect("changed",self,"upd")
