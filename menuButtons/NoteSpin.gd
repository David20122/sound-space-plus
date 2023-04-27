extends SpinBox

func upd():
	if name == "NoteSpinX":
		SSP.note_spin_x = value
	elif name == "NoteSpinY":
		SSP.note_spin_y = value
	elif name == "NoteSpinZ":
		SSP.note_spin_z = value

func _process(_d):
	if name == "NoteSpinX":
		if value != SSP.note_spin_x: upd()
	elif name == "NoteSpinY":
		if value != SSP.note_spin_y: upd()
	elif name == "NoteSpinZ":
		if value != SSP.note_spin_z: upd()

func _ready():
	if name == "NoteSpinX":
		value = SSP.note_spin_x
	elif name == "NoteSpinY":
		value = SSP.note_spin_y
	elif name == "NoteSpinZ":
		value = SSP.note_spin_z
	connect("changed",self,"upd")
