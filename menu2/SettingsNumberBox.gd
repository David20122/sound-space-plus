extends SpinBox

export(String) var target

func upd():
	SSP.set(target,value)

func _process(_d):
	if value != SSP.get(target): upd()
	
func _ready():
	value = SSP.get(target)
	connect("changed",self,"upd")
