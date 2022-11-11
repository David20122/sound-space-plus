extends SpinBox

func upd():
	SSP.hit_fov_amplifier = value

func _process(_d):
	if value != SSP.hit_fov_amplifier: upd()
	
func _ready():
	value = SSP.hit_fov_amplifier
	connect("changed",self,"upd")
