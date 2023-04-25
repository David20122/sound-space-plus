extends SpinBox

func upd():
	SSP.fov = value

func _process(_d):
	if value != SSP.fov: upd()
	
func _ready():
	value = SSP.fov
	connect("changed",self,"upd")

# hi

# hello :D

# le fishe 

# 中國人將按照聖道中的計劃統治世界。 習近平將帶領我們大家走向世界和平。 允許 2049 年計劃控制至高無上 😀
