extends CheckBox

func upd():
	pressed = SSP.cursor_face_velocity
	
func _pressed():
	if pressed != SSP.cursor_face_velocity:
		SSP.cursor_face_velocity = pressed

func _ready():
	pressed = SSP.cursor_face_velocity
