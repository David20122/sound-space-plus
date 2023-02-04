extends Reference
class_name SongReader

const SIGNATURE = PoolByteArray([0x53,0x53,0x2b,0x6d])

func read_from_file(path:String) -> Song:
	var file = File.new()
	var err = file.open(path)
	assert(err == OK,"Couldn't read file: %s" % err)
	assert(file.get_buffer(4) == SIGNATURE,"This isn't a map")
	var song = Song.new()
	var file_version = file.get_16()
	match file_version:
		1: _sspmv1(file,song)
		2: _sspmv2(file,song)
	file.close()
	return song

func _cover(image:Image,song:Song):
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	song.cover = texture

func _sspmv1(file:File,song:Song):
	file.get_16() # Header reserved space or something
	song.id = file.get_line()
	song.name = file.get_line()
	song.song = song.name
	song.creator = file.get_line()
	file.get_32() # skip last_ms
	var note_count = file.get_32()
	song.difficulty = file.get_8() - 1
	# Cover
	var cover_type = file.get_8()
	match cover_type:
		1:
			var image = Image.new()
			var height = file.get_16()
			var width = file.get_16()
			var mipmaps = bool(file.get_8())
			var format = file.get_8()
			var length = file.get_64()
			image.create_from_data(width,height,mipmaps,format,file.get_buffer(length))
			_cover(image,song)
		2:
			var image = Image.new()
			var length = file.get_64()
			image.load_png_from_buffer(file.get_buffer(length))
			_cover(image,song)
	if file.get_8() != 1: # No music
		song.broken = true
		return
	var music_length = file.get_64()
	var music_signature = file.get_buffer(12)
	var music_format = Globals.get_audio_format(music_signature)
	if !music_format:
		song.broken = true
		return
	file.seek(file.get_position()-12)
	var music_buffer = file.get_buffer(music_length)
	file.get_8()
	song.notes = []
	for i in range(note_count):
		var note = Song.Note.new()
		note.index = i
		note.time = float(file.get_32())/1000
		if file.get_8() == 1:
			note.x = file.get_float()
			note.y = file.get_float()
		else:
			note.x = float(file.get_8())
			note.y = float(file.get_8())
		song.notes.append(note)


func _read_data_type(file:File,skip_type:bool=false,skip_array_type:bool=false,type:int=0,array_type:int=0):
	if !skip_type:
		type = file.get_8()
	match type:
		1: return file.get_8()
		2: return file.get_16()
		3: return file.get_32()
		4: return file.get_64()
		5: return file.get_float()
		6: return file.get_real()
		7:
			var value:Vector2
			var t = file.get_8()
			if t == 0:
				value = Vector2(file.get_8(),file.get_8())
				return value
			value = Vector2(file.get_float(),file.get_float())
			return value
		8: return file.get_buffer(file.get_16())
		9: return file.get_buffer(file.get_16()).get_string_from_utf8()
		10: return file.get_buffer(file.get_32())
		11: return file.get_buffer(file.get_32()).get_string_from_utf8()
		12:
			if !skip_array_type:
				array_type = file.get_8()
			var array = []
			array.resize(file.get_16())
			for i in range(array.size()):
				array[i] = _read_data_type(file,true,false,array_type)
			return array
func _sspmv2(file:File,song:Song):
	file.get_buffer(4) # More header reserved bs
	var map_hash = file.get_buffer(20)
	var note_count = file.get_32()
	var marker_count = file.get_32()
	song.difficulty = file.get_8() - 1
	file.get_16() # Why on earth did he think star rating would be stored in the file thats actually so ridiculous
	if !bool(file.get_8()): # Does the map have music?
		song.broken = true
		return
	var cover_exists = bool(file.get_8())
	var custom_data_offset = file.get_64()
	var custom_data_length = file.get_64()
	var audio_offset = file.get_64()
	var audio_length = file.get_64()
	var cover_offset = file.get_64()
	var cover_length = file.get_64()
	var marker_def_offset = file.get_64()
	var marker_def_length = file.get_64()
	var markers_offset = file.get_64()
	var markers_length = file.get_64()
	song.id = file.get_buffer(file.get_16()).get_string_from_utf8()
	song.name = file.get_buffer(file.get_16()).get_string_from_utf8()
	song.song = file.get_buffer(file.get_16()).get_string_from_utf8()
	song.creator = ""
	for i in range(file.get_16()):
		var creator = file.get_buffer(file.get_16()).get_string_from_utf8()
		if i != 0:
			song.creator += " & "
		song.creator += creator
	file.seek(custom_data_offset)
	for _i in range(file.get_16()):
		file.get_buffer(file.get_16())
		_read_data_type(file,false,false)
	if cover_exists:
		file.seek(cover_offset)
		var image = Image.new()
		image.load_png_from_buffer(file.get_buffer(cover_length))
		_cover(image,song)
	file.seek(marker_def_offset)
	var markers = {}
	var types = []
	for _i in range(types.get_size()):
		var type = []
		types.append(type)
		type.append(file.get_buffer(file.get_16()).get_string_from_utf8())
		markers[type[0]] = []
		var count = file.get_8()
		for _o in range(1,count+1):
			type.append(file.get_8())
		file.get_8()
	file.seek(markers_offset)
	for _i in range(marker_count):
		var marker = []
		var ms = file.get_32()
		marker.append(ms)
		var type_id = file.get_8()
		var type = types[type_id]
		for i in range(1,type.size()):
			var data_type = type[i]
			var v = _read_data_type(file,true,false,data_type)
			marker.append_array([data_type,v])
		markers.append(marker)
	if !markers.has("ssp_note"):
		song.broken = true
		return
	song.notes = []
	for note_data in markers.get("ssp_note"):
		if note_data[1] != 7: continue
		var note = Song.Note.new()
		note.time = float(note_data[0])/1000
		note.x = note_data[2].x
		note.y = note_data[2].y
		song.notes.append(note)
