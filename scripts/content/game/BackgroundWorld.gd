extends Resource
class_name BackgroundWorld

var id: String
var name: String
var creator: String = "Unknown"
var path: String

var cover: Texture = null
var has_cover: bool = false

func load_png(file: String) -> Texture:
	if file.begins_with("res://"):
		return ResourceLoader.load(file) as Texture
	var imgtex = ImageTexture.new()
	if imgtex.load(file) != OK:
		print("Error loading image from path: ", file)
		return null
	return imgtex

func _init(idI: String, nameI: String, pathI: String, creatorI: String = "Unknown", coverI: String = ""):
	id = idI
	name = nameI
	creator = creatorI
	path = pathI
	if coverI != "":
		var c = load_png(coverI)
		if c:
			cover = c
			has_cover = true
