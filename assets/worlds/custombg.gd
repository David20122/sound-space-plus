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
