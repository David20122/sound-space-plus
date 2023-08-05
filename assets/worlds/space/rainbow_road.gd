extends MeshInstance

func _process(delta):
	transform.origin += Vector3(0,0,delta*(Rhythia.get("approach_rate")*0.1))
	if transform.origin.z >= 6: transform.origin.z -= 6

func _ready():
	if Rhythia.vr:
		$Vignette.visible = false
	if Rhythia.selected_space.id == "ssp_rainbow_road_nb":
		get_parent().get_node("WorldEnvironment").environment.glow_enabled = false
