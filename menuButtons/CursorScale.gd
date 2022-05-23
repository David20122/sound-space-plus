extends SpinBox

func upd():
	SSP.cursor_scale = value

func _process(_d):
	if value != SSP.cursor_scale: upd()

func _ready():
	value = SSP.cursor_scale
	connect("changed",self,"upd")
