extends SpinBox

func upd():
	Rhythia.note_hitbox_size = float(str(value))
	# spinbox 1.14 != float literal 1.14 for some reason

func _process(_d):
	if str(value) != str(Rhythia.note_hitbox_size): upd()
	
func _ready():
	value = Rhythia.note_hitbox_size
	connect("changed",self,"upd")
