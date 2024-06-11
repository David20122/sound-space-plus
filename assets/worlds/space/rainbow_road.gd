extends MeshInstance

func _process(delta):
	transform.origin += Vector3(0,0,delta*(Rhythia.get("approach_rate")*0.1))
	if transform.origin.z >= 6.45: transform.origin.z -= 6.45

func _ready():
	if Rhythia.vr:
		$Vignette.visible = false
	# Shaders
	var env = get_parent().get_node("WorldEnvironment").environment
	if Rhythia.glow > 0:
		env.glow_enabled = true
		env.glow_intensity = Rhythia.glow
		env.glow_strength = 1
		env.glow_bloom = Rhythia.bloom
		env.glow_blend_mode = 1
		env.glow_hdr_scale = 1.72
		env.glow_high_quality = true
		env.glow_bicubic_upscale = true
