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
	
func _ready():
	# Shaders
	var env = get_node("WorldEnvironment").environment
	if Rhythia.glow > 0:
		env.glow_enabled = true
		env.glow_intensity = Rhythia.glow
		env.glow_strength = 1
		env.glow_bloom = Rhythia.bloom
		env.glow_blend_mode = 1
		env.glow_hdr_scale = 1.72
		env.glow_high_quality = true
		env.glow_bicubic_upscale = true
