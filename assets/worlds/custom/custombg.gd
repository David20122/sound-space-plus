extends Spatial

func _ready():
	var env = $WorldEnvironment.environment
	var pano = Globals.imageLoader.load_if_exists("user://panobg")
	if pano:
		var sky:PanoramaSky = env.background_sky
		sky.panorama = pano
	else:
		var img = Globals.imageLoader.load_if_exists("user://custombg")
		if img: $V/R.material.set_shader_param("tex",img)
	# Shaders
	if Rhythia.glow > 0:
		env.glow_enabled = true
		env.glow_intensity = Rhythia.glow
		env.glow_strength = 1
		env.glow_bloom = Rhythia.bloom
		env.glow_blend_mode = 1
		env.glow_hdr_scale = 1.72
		env.glow_high_quality = true
		env.glow_bicubic_upscale = true
