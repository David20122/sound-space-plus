extends MeshInstance

func _process(delta):
	transform.origin += Vector3(0,0,delta*(SSP.approach_rate*0.1))
	if transform.origin.z >= 6: transform.origin.z -= 6

func _ready():
	if SSP.vr:
		$Vignette.visible = false
