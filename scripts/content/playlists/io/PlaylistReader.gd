extends Object
class_name PlaylistReader

const SIGNATURE:PackedByteArray = [0x53,0x53,0x2b,0x6c]

func read_from_file(path:String):
	var file = FileAccess.open(path,FileAccess.READ)
	assert(file != null)
	assert(file.get_buffer(4) == SIGNATURE)
	var playlist = Playlist.new()
	playlist.path = path
	
	# Metadata
	var id = FileAccess.get_md5(file.get_path())
	playlist.id = id
	var online_id_length = file.get_8() # Online ID
	if online_id_length > 0: playlist.online_id = file.get_buffer(online_id_length).get_string_from_ascii()
	var name_length = file.get_16() # List name
	playlist.name = file.get_buffer(name_length).get_string_from_utf16()
	var creator_length = file.get_16() # List creator
	playlist.creator = file.get_buffer(creator_length).get_string_from_utf16()
	
	# Cover
	var cover_width = file.get_16()
	if cover_width > 1:
		var cover_height = file.get_16()
		var cover_length = file.get_64()
		var cover_buffer = file.get_buffer(cover_length)
		var image = Image.create_from_data(cover_width,cover_height,false,Image.FORMAT_RGBA8,cover_buffer)
		playlist.cover = ImageTexture.create_from_image(image)
		
	# Data
	var map_count = file.get_16()
	playlist._mapsets = []
	for i in range(map_count):
		var type = file.get_8()
		var ptr_length = file.get_16()
		var ptr = file.get_buffer(ptr_length).get_string_from_utf8()
		playlist._mapsets.append({type=type, pointer=ptr})
		
	return playlist
