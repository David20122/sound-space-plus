extends Spatial

export(SpatialMaterial) var mat
export(SpatialMaterial) var mat2
var colors:Array = SSP.selected_colorset.colors


#var target_color:Color = colors[0] * 0.5

func hit(col:Color):
#	target_color = col * 0.5
	mat.albedo_color = col
	mat2.albedo_color = col
#	$WorldEnvironment.environment.fog_sun_color = col * 0.5

func _ready():
	mat.albedo_color = colors[0]
	mat2.albedo_color = colors[0]
	get_parent().get_node("Game").connect("hit",self,"hit")
	#$WorldEnvironment.environment = $WorldEnvironment.environment.duplicate()

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
