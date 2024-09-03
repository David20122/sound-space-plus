extends Resource
class_name ColorSet

export(String) var id
export(String) var name
export(String) var creator = "Unknown"
export(Array, Color) var colors setget _set_colors, _get_colors
var real_colors: Array = []
export(bool) var mirror = false

func _get_colors() -> Array:
	if mirror and colors.size() == 0:
		colors = real_colors.duplicate()
		for i in range(real_colors.size() - 2, -1, -1):
			colors.append(real_colors[i])
	return colors if mirror else real_colors

func _set_colors(value: Array) -> void:
	real_colors = value
	colors.clear()

func _init(colorsI: Array, idI: String, nameI: String, creatorI: String = "Unknown") -> void:
	id = idI
	name = nameI
	real_colors = colorsI
	creator = creatorI
	colors.clear()
