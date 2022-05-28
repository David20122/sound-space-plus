extends MeshInstance

func _process(delta):
	transform.origin += Vector3(0,0,delta*(SSP.approach_rate*0.1))
	if transform.origin.z >= 6: transform.origin.z -= 6

#func _ready():
#	var m:SpatialMaterial = mesh.surface_get_material(0)
#	if SSP.mod_nearsighted:
#		m.distance_fade_min_distance = 30
#		m.distance_fade_max_distance = 5
#	elif SSP.mod_ghost:
#		m.distance_fade_max_distance = 10
#		m.distance_fade_min_distance = 0
#	else:
#		m.distance_fade_min_distance = SSP.spawn_distance + min(SSP.approach_rate * 0.2, SSP.spawn_distance * 0.6)
#		m.distance_fade_max_distance = SSP.spawn_distance - min(SSP.approach_rate * 0.2, SSP.spawn_distance * 0.6)
