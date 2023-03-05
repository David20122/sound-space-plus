extends PopupPanel

func _ready():
	reset()
	connect("about_to_popup",Callable(self,"reset"))
	$Options/CoverSelect.connect("pressed",Callable($Options/CoverSelect/FileDialog,"popup_centered"))
	$Options/CoverSelect/FileDialog.connect("file_selected",Callable(self,"cover_selected"))
	$Options/Confirm.connect("pressed",Callable(self,"confirm"))

var selected_cover:Texture
func cover_selected(file:String):
	selected_cover = load(file)
	$Options/Cover.texture = selected_cover
func reset():
	selected_cover = preload("res://assets/images/covers/logic-alt.png")
	$Options/Cover.texture = selected_cover
	$Options/Title.clear()
	$Options/Author.clear()

func confirm():
	var title = $Options/Title.text
	var author = $Options/Author.text
	if title.length() == 0 or author.length() == 0: return
	var playlist = Playlist.new()
	playlist.id = "%s - %s_%s" % [title,author,Time.get_ticks_msec()]
	playlist.path = Globals.Folders.get("playlists").path_join(playlist.id)
	playlist.name = title
	playlist.creator = author
	playlist.cover = selected_cover
	playlist._mapsets = []
	var writer = PlaylistWriter.new()
	writer.write_to_file(playlist,playlist.path)
	writer.free()
	SoundSpacePlus.playlists.add_item(playlist)
	print("Created new playlist")
	hide()
