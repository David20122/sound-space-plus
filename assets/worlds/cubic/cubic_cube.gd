extends MeshInstance

var rot:Vector3 = Vector3()
var boost:float = 0

func _ready():
	var mat:ShaderMaterial = mesh.surface_get_material(0).duplicate()
	mesh = mesh.duplicate()
	mesh.surface_set_material(0,mat)
	mat.set_shader_param("albedo",Color.firebrick * clamp((76 + global_transform.origin.z)/75,0.35,1))
	rot = Vector3(randf(),randf(),randf()).normalized()
	rotate(rot,randf())
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


func _process(delta):
	rotate(rot,delta*(0.035+(boost)))
	if boost != 0:
		boost = max(lerp(boost,0,delta*3.7) - delta,0)
		var sm = 0.3
		scale = Vector3((boost*sm)+1,(boost*sm)+1,(boost*sm)+1)
