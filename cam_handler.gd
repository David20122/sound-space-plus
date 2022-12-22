extends Spatial

var state = (SSP.replaying and SSP.alt_cam)

func _ready():
	PhysicsServer.set_active(!SSP.visual_mode and (SSP.cam_unlock or SSP.vr))
	
	# alt camera init
	if state:
		$Camera.current = false
		$AltCam.current = true
		$AltCam.set_enabled(true)
		$Game/Avatar.visible = true
		$Game/Avatar/Animations.play("Idle")
		$Game/Avatar/Head/Blinking.play("Blink")
	else:
		$AltCam.set_enabled(false)
		$Game/Avatar.visible = false
		$Camera.current = true
		$AltCam.current = false
	
	if SSP.mod_flashlight:
		$Game/Mask.visible = true
	else:
		$Game/Mask.visible = false # should already be false but just to ensure that it is

func _process(delta):
	if Input.is_action_just_pressed("debug_freecam_toggle"):
		state = !state
		_ready()
