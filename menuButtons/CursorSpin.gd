extends SpinBox

func upd():
	SSP.cursor_spin = value

func _process(_d):
	if value != SSP.cursor_spin: upd()

func _ready():
	value = SSP.cursor_spin
	connect("changed",self,"upd")
