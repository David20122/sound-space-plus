extends SpinBox

func upd():
	SSP.hit_fov_decay = value

func _process(_d):
	if value != SSP.hit_fov_decay: upd()
	
func _ready():
	value = SSP.hit_fov_decay
	connect("changed",self,"upd")
