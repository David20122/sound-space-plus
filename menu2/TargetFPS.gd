extends SpinBox

func upd():
	if value < 15 and value != 0:
		value = 15
	Engine.target_fps = value

func _process(_d):
	if value != Engine.target_fps: upd()
	
func _ready():
	value = Engine.target_fps
	connect("changed",self,"upd")
