extends SpinBox

func upd():
	Rhythia.hit_fov_amplifier = value

func _process(_d):
	if value != Rhythia.hit_fov_amplifier: upd()
	
func _ready():
	value = Rhythia.hit_fov_amplifier
	connect("changed",self,"upd")
