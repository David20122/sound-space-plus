extends SpinBox

func upd():
	Rhythia.hit_fov_decay = value

func _process(_d):
	if value != Rhythia.hit_fov_decay: upd()
	
func _ready():
	value = Rhythia.hit_fov_decay
	connect("changed",self,"upd")
