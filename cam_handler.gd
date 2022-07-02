extends Spatial

func _ready():
	if SSP.replaying and SSP.alt_cam:
		$Camera.current = false
		$AltCam.current = true
		$AltCam.set_enabled(true)
		$Game/Avatar.visible = true
		$Game/Avatar/Animations.play("Idle")
	else:
		$AltCam.set_enabled(false)
		$Game/Avatar.visible = false
		$Camera.current = true
		$AltCam.current = false
