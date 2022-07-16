extends Camera

var yaw = 0
var pitch = 0

var active = false

func _input(event):
#	if SSP.fake_vr:
	if active:
		if (event is InputEventMouseMotion) or (event is InputEventScreenDrag):
			yaw = fmod(yaw - event.relative.x * SSP.sensitivity * 0.2, 360)
			pitch = max(min(pitch - event.relative.y * SSP.sensitivity * 0.2, 89), -89)
			get_parent().rotation = Vector3(deg2rad(pitch), deg2rad(yaw), 0)

func _process(delta):
#	if SSP.fake_vr:
	if !current:
		make_current()

	if Input.is_action_just_pressed("fc_trigger"):
		active = !active
		if active:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _ready():
	set_process(SSP.fake_vr)
	set_process_input(SSP.fake_vr)
