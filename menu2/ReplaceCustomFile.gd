extends Button
var dir:Directory = Directory.new()

export(String) var target = "cursor"
export(Texture) var default_image

enum KIND {
	IMAGE
	SOUND
}

export(KIND) var kind = KIND.IMAGE

var copy_old_from:String

func save_sel(file:String):
	dir.copy(copy_old_from,file)

func rename_old(ext:String):
	var dt = OS.get_datetime()
	copy_old_from = Globals.p("user://%s.%s" % [target,ext])
	$SaveFile.filters = [
		"*.%s ; %s file" % [ext,ext]
	]
	$SaveFile.initial_path = "~/Downloads/%s.%s" % [target,ext] 
	$SaveFile.show()

func sel(files:Array):
	if files.size() != 0:
		if kind == KIND.IMAGE:
			Globals.confirm_prompt.open(
				"Are you sure? This will overwrite the previous image!",
				"Replace Custom Asset",
				[
					{ text = "Cancel" },
					{ text = "Save old image" },
					{ text = "OK", wait = 2 }
				]
			)
			var response:int = yield(Globals.confirm_prompt,"option_selected")
			while response == 1:
				if dir.file_exists(Globals.p("user://%s.png" % target)): rename_old("png")
				elif dir.file_exists(Globals.p("user://%s.jpg" % target)): rename_old("jpg")
				elif dir.file_exists(Globals.p("user://%s.jpeg" % target)): rename_old("jpeg")
				elif dir.file_exists(Globals.p("user://%s.webp" % target)): rename_old("webp")
				elif dir.file_exists(Globals.p("user://%s.bmp" % target)): rename_old("bmp")
				response = yield(Globals.confirm_prompt,"option_selected")
			if response == 2:
				dir.copy(files[0],Globals.p("user://%s.%s" % [target,files[0].get_extension()]))
				
				var tex = Globals.imageLoader.load_if_exists("user://" + target)
				if tex: $ImgPreview.texture = tex
				else: $ImgPreview.texture = default_image
			else: print("cancelled")
			Globals.confirm_prompt.close()
		else:
			pass

func _pressed():
	if kind == KIND.IMAGE:
		Globals.file_sel.open_file(self,"sel",PoolStringArray(["*.png, *.jpg, *.jpeg, *.webp, *.bmp ; Image files"]))

func _ready():
	$OpenFile.connect("files_selected",self,"sel")
	$SaveFile.connect("file_selected",self,"save_sel")
	if kind == KIND.IMAGE:
		$ImgPreview.visible = true
		var tex = Globals.imageLoader.load_if_exists("user://"+target)
		if tex: $ImgPreview.texture = tex
		else: $ImgPreview.texture = default_image
	else:
		$ImgPreview.visible = false
