extends SpinBox

func upd():
	SSP.grid_parallax = value

func _process(_d):
	if value != SSP.grid_parallax: upd()
	
func _ready():
	value = SSP.grid_parallax
	connect("changed",self,"upd")
