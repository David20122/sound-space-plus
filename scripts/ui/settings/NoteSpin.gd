extends SpinBox

func upd():
	if name == "NoteSpinX":
		Rhythia.note_spin_x = value
	elif name == "NoteSpinY":
		Rhythia.note_spin_y = value
	elif name == "NoteSpinZ":
		Rhythia.note_spin_z = value

func _process(_d):
	if name == "NoteSpinX":
		if value != Rhythia.note_spin_x: upd()
	elif name == "NoteSpinY":
		if value != Rhythia.note_spin_y: upd()
	elif name == "NoteSpinZ":
		if value != Rhythia.note_spin_z: upd()

func _ready():
	if name == "NoteSpinX":
		value = Rhythia.note_spin_x
	elif name == "NoteSpinY":
		value = Rhythia.note_spin_y
	elif name == "NoteSpinZ":
		value = Rhythia.note_spin_z
	connect("changed",self,"upd")
