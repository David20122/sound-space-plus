extends MeshInstance

func _process(delta):
	transform.origin += Vector3(0,0,delta*(SSP.get("approach_rate")*0.1))
	if transform.origin.z >= 45: transform.origin.z -= 105
