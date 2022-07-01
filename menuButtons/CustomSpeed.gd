extends SpinBox

func upd():
	print("changing the thigny")
	SSP.custom_speed = value / 100

func _process(_d):
	if value != SSP.custom_speed * 100: upd()

func _ready():
	value = SSP.custom_speed * 100
	connect("changed",self,"upd")
