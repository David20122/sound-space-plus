extends Spatial

#export(SpatialMaterial) var mat
#var colors:Array = SSP.selected_colorset.colors


#var target_color:Color = colors[0] * 0.5

func hit(col:Color):
	$Cubes.get_child(randi() % $Cubes.get_child_count()).boost = 1

func _ready():
	get_parent().get_node("Game").connect("hit",self,"hit")
