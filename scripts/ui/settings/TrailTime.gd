extends SpinBox

func upd():
	SSP.trail_time = float(str(value))

func _process(_d):
	if float(str(value)) != float(str(SSP.trail_time)): upd()

func _ready():
	value = float(str(SSP.trail_time))
	connect("changed",self,"upd")
