extends Resource
class_name ColorSet

export(String) var id
export(String) var name
export(String) var creator
export(Array,Color) var colors setget _set_colors,_get_colors
var real_colors:Array
export(bool) var mirror

func _get_colors():
	if mirror:
		if colors.size() == 0:
			for c in real_colors:
				colors.append(c)
			for i in range(real_colors.size()-2,0,-1):
				colors.append(real_colors[i])
		return colors
	else:
		return real_colors

func _set_colors(v:Array):
	real_colors = v
	colors = []

func _init(colorsI:Array, idI:String, nameI:String, creatorI:String="Unknown"):
	id = idI
	name = nameI
	real_colors = colorsI
	creator = creatorI
