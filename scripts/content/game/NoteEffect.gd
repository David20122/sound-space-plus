extends Resource
class_name NoteEffect

export var id: String
export var name: String
export var creator: String = "Unknown"
export var path: String

func _init(idI: String, nameI: String, pathI: String, creatorI: String = "Unknown"):
	id = idI
	name = nameI
	path = pathI
	creator = creatorI
