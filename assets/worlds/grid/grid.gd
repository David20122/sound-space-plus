extends Spatial

var rate:float = 6
var s:float = -26
var e:float = -14.1
var gcol:Color
var color:Color = Rhythia.selected_colorset.colors[0]
var ratec:float = 0.005
var rng = RandomNumberGenerator.new()
var particle = preload("res://assets/worlds/grid/cube.tscn")

func hit(col:Color):
	color = col
	if !Rhythia.disable_bg_effects:
		var particle_instance = particle.instance()
		particle_instance.translate(Vector3(rand_range(-$emissionArea.scale.x, $emissionArea.scale.x), 4, rand_range(-$emissionArea.scale.z, $emissionArea.scale.z)))
		if (particle_instance.translation.x >= -5 and particle_instance.translation.x <= 5):
			return
		particle_instance.process_material.color = color
		particle_instance.process_material.scale = rand_range(0.5, 1)
		particle_instance.speed_scale = rand_range(1, 2)
		particle_instance.lifetime = 2
		particle_instance.restart()
		particle_instance.emitting = true
		$Particles.call_deferred("add_child", particle_instance)
		get_tree().create_timer(particle_instance.lifetime).connect("timeout", particle_instance, "queue_free")

func _ready():
	get_parent().get_node("Game").connect("hit",self,"hit")
		
func _process(delta):
	$gridBottom.translation.z += rate * delta 
	$gridTop.translation.z += rate * delta 
	
	$gridBottom.translation.z = wrapf($gridBottom.translation.z,s,e)
	$gridTop.translation.z = wrapf($gridTop.translation.z,s,e)

	gcol = Color(color.r,color.g,color.b,0.01)

	$gridBottom.material_override.albedo_color = lerp($gridBottom.material_override.albedo_color,gcol,ratec)
	$gridTop.material_override.albedo_color = lerp($gridTop.material_override.albedo_color,gcol,ratec)
	$gridBottomF.material_override.albedo_color = lerp($gridBottomF.material_override.albedo_color,gcol,ratec)
	$gridTopF.material_override.albedo_color = lerp($gridTopF.material_override.albedo_color,gcol,ratec)
