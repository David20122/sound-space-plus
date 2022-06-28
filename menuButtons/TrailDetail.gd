extends SpinBox

func upd():
	SSP.trail_detail = value

func _process(_d):
	if value != SSP.trail_detail: upd()

func _ready():
	value = SSP.trail_detail
	connect("changed",self,"upd")
