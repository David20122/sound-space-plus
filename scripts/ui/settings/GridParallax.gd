extends SpinBox

func upd():
	Rhythia.grid_parallax = value

func _process(_d):
	if value != Rhythia.grid_parallax: upd()
	
func _ready():
	value = Rhythia.grid_parallax
	connect("changed",self,"upd")
