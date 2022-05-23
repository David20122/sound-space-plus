extends Spatial

var colors:Array = SSP.selected_colorset.colors

var target_color:Color = colors[0] * 0.5

func hit(col:Color):
	target_color = col * 0.5
#	$WorldEnvironment.environment.fog_sun_color = col * 0.5

func _process(delta):
	delta *= 10
	delta = min(delta,1)
	$WorldEnvironment.environment.fog_sun_color = (target_color * delta) + ($WorldEnvironment.environment.fog_sun_color * (1-delta))

func _ready():
	$WorldEnvironment.environment = $WorldEnvironment.environment.duplicate()
	get_parent().get_node("Game").connect("hit",self,"hit")

#func _ready():
#	var i:int = 0
#	for n in get_children():
#		var mat:SpatialMaterial = n.get_surface_material(0).duplicate()
#		n.set_surface_material(0,mat)
#		var col = colors[i]
#		mat.albedo_color = Color(0, 0, 0)# 150.0/255.0)
##		mat.albedo_color = Color(col.r * 0.4, col.g * 0.4, col.b * 0.4)# 150.0/255.0)
#		i += 1
#		if i == colors.size(): i = 0
