extends SpinBox

export(String) var target

func upd():
	Rhythia.set(target,value)

func _process(_d):
	if value != Rhythia.get(target): upd()
	
func _ready():
	value = Rhythia.get(target)
	connect("changed",self,"upd")
