extends Spatial

func _ready():
	$Game/Avatar.visible = false
	if SSP.replaying and SSP.alt_cam:
		$Camera.current = false
		$AltCam.current = true
		$Game/Avatar.visible = true
		$Game/Avatar/Animations.play("Idle")
