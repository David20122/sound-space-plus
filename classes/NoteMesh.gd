extends Resource
class_name NoteMesh

var id:String
var name:String
var creator:String

var path:String

var cover:Texture
var has_cover:bool = false

func load_png(file:String):
	var imgtex = ImageTexture.new()
	var res = imgtex.load(file)
	if res != OK: return null
	else: return imgtex

func _init(idI:String,nameI:String,pathI:String,creatorI:String="Unknown",coverI:String=""):
	id = idI
	name = nameI
	creator = creatorI
	path = pathI
	if coverI != "":
		var c = load_png(coverI)
		if c:
			cover = c
			has_cover = true
