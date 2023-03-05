extends Object
class_name PlaylistWriter

const SIGNATURE:PackedByteArray = [0x53,0x53,0x2b,0x6c]

func write_to_file(playlist:Playlist,path:String):
	if !path.ends_with(".sspl"): path = "%s.sspl" % path
	
	var file = FileAccess.open(path,FileAccess.WRITE)
	file.store_buffer(SIGNATURE)
	
	# Metadata
	if playlist.online_id != null:
		var online_id_buffer = playlist.online_id.to_ascii_buffer() # Online ID
		file.store_8(online_id_buffer.size())
		file.store_buffer(online_id_buffer)
	else:
		file.store_8(0)
	var name_buffer = playlist.name.to_utf16_buffer() # Playlist name
	file.store_16(name_buffer.size())
	file.store_buffer(name_buffer)
	var creator_buffer = playlist.creator.to_utf16_buffer() # Playlist creator
	file.store_16(creator_buffer.size())
	file.store_buffer(creator_buffer)
	
	# Cover
	if playlist.cover != null:
		var cover_image = playlist.cover.get_image()
		if cover_image.get_format() != Image.FORMAT_RGBA8: cover_image.convert(Image.FORMAT_RGBA8) # Image format will ALWAYS be RGBA8
		var cover_width = min(1024,cover_image.get_width()) # Maximum 1024x1024
		var cover_height = min(1024,cover_image.get_height())
		cover_image.resize(cover_width,cover_height)
		file.store_16(cover_width) # Store width and height before data
		file.store_16(cover_height)
		var cover_buffer = cover_image.get_data() # Store cover data
		file.store_64(cover_buffer.size())
		file.store_buffer(cover_buffer)
	else:
		file.store_16(0)
		
	# Data
	file.store_16(playlist._mapsets.size())
	for map in playlist._mapsets:
		file.store_8(map.type)
		var ptr = map.pointer.to_utf8_buffer()
		file.store_16(ptr.size())
		file.store_buffer(ptr)
