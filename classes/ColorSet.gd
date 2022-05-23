extends Resource
class_name ColorSet

export(String) var id
export(String) var name
export(String) var creator
export(Array,Color) var colors

func _init(colorsI:Array, idI:String, nameI:String, creatorI:String="Unknown"):
	id = idI
	name = nameI
	colors = colorsI
	creator = creatorI
