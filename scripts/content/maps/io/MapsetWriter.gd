extends Object
class_name MapsetWriter

const SIGNATURE:PackedByteArray = [0x53,0x53,0x2b,0x6d]

func write_to_file(set:Mapset,path:String):
	var file = FileAccess.open(path,FileAccess.WRITE)
	file.store_buffer(SIGNATURE)
	file.store_16(3) # File version
	file.store_16(0) # Empty bytes
	
	# Metadata
	if set.online_id != null:
		var online_id_buffer = set.online_id.to_ascii_buffer() # Online ID
		file.store_8(online_id_buffer.size())
		file.store_buffer(online_id_buffer)
	else:
		file.store_8(0)
	var name_buffer = set.name.to_utf16_buffer() # Map name
	file.store_16(name_buffer.size())
	file.store_buffer(name_buffer)
	var creator_buffer = set.creator.to_utf16_buffer() # Map creator
	file.store_16(creator_buffer.size())
	file.store_buffer(creator_buffer)
	
	# Audio
	if set.audio != null:
		var audio_buffer = set.audio.data
		file.store_64(audio_buffer.size())
		file.store_buffer(audio_buffer)
	else:
		file.store_64(0)
	
	# Cover
	if set.cover != null:
		var cover_image = set.cover.get_image()
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
	
	file.store_8(set.maps.size()) # Number of maps in file, assume this is always 1 for now
	for i in range(set.maps.size()):
		# Store the difficulty's name, then the data
		var map = set.maps[i]
		var dname_buffer = map.name.to_utf16_buffer()
		file.store_16(dname_buffer.size())
		file.store_buffer(dname_buffer)
		var map_data = JSON.stringify(serialise_data(map)).to_utf8_buffer()
		file.store_64(map_data.size())
		file.store_buffer(map_data)

func serialise_data(map:Map): # Serialise map data to Dictionary
	var data = {}
	data.version = 1
	data.notes = []
	for note in map.notes:
		data.notes.append({index=note.index,position=[note.x,note.y],time=note.time})
	return data
