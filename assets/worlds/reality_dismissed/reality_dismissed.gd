extends Spatial

func _process(delta):
	
	# Cube
	$cube.rotation_degrees.x += (45 / 2)  * delta
	$cube.rotation_degrees.x += (15 / 2)  * delta
	$cube.rotation_degrees.z += (90 / 2)  * delta
	
	# Prism
	$prism.rotation_degrees.x -= (45 / 2)  * delta
	$prism.rotation_degrees.x -= (15 / 2)  * delta
	$prism.rotation_degrees.z -= (90 / 2)  * delta
