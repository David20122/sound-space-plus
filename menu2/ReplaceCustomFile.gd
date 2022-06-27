extends Button
var dir:Directory = Directory.new()

export(String) var target = "cursor"
export(Texture) var default_image

enum KIND {
	IMAGE
	SOUND
}

export(KIND) var kind = KIND.IMAGE

var zero = 0

func rename_old(ext:String):
	var dt = OS.get_datetime()
	if dir.file_exists("user://%s.%s" % [target,ext]):
		dir.rename(
			"user://%s.%s" % [target,ext],
			"user://%s_old_%s-%s-%s_%s-%s-%s.%s" % [
				target, dt.year,dt.month,dt.day,
				dt.hour,dt.minute,dt.second, ext
			]
		)

func sel(files:Array):
	if files.size() != 0:
		if kind == KIND.IMAGE:
			if dir.file_exists("user://%s.png" % target): rename_old("png")
			elif dir.file_exists("user://%s.jpg" % target): rename_old("jpg")
			elif dir.file_exists("user://%s.jpeg" % target): rename_old("jpeg")
			elif dir.file_exists("user://%s.webp" % target): rename_old("webp")
			elif dir.file_exists("user://%s.bmp" % target): rename_old("bmp")
			dir.copy(files[0],"user://%s.%s" % [target,files[0].get_extension()])
			
			var tex = Globals.imageLoader.load_if_exists("user://" + target)
			if tex: $ImgPreview.texture = tex
			else: $ImgPreview.texture = default_image
		else:
			pass

func _pressed():
	
	$OpenFile.show()

func _ready():
	$OpenFile.connect("files_selected",self,"sel")
	if OS.has_feature("mobile"):
		disabled = true
		text = "Not supported yet"
		# We currently don't have a way to open file dialogs on mobile
	if kind == KIND.IMAGE:
		$ImgPreview.visible = true
		var tex = Globals.imageLoader.load_if_exists("user://"+target)
		if tex: $ImgPreview.texture = tex
		else: $ImgPreview.texture = default_image
	else:
		$ImgPreview.visible = false
