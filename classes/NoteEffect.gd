extends Resource
class_name NoteEffect

export(String) var id
export(String) var name
export(String) var creator
export(String, FILE, "*.tscn") var path

func _init(idI:String, nameI:String, pathI:String, creatorI:String="Unknown"):
	id = idI
	name = nameI
	path = pathI
	creator = creatorI
