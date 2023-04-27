extends SpinBox

func upd():
	SSP.note_opacity = clamp(value / 100,0,1)

func _process(_d):
	if (value / 100) != SSP.note_opacity: upd()

func _ready():
	value = SSP.note_opacity * 100
	connect("changed",self,"upd")
