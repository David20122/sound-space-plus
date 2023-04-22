extends Object
class_name MapsetReader

const SIGNATURE:PackedByteArray = [0x53,0x53,0x2b,0x6d]

static func read_from_file(path:String,full:bool=false,index:int=0) -> Mapset:
	var file = FileAccess.open(path,FileAccess.READ)
	assert(file != null)
	assert(file.get_buffer(4) == SIGNATURE)
	var set = Mapset.new()
	var file_version = file.get_16()
	set.path = path
	set.format = file_version
	match file_version:
		1: _sspmv1(file,set,full)
		2: _sspmv2(file,set,full)
		3: _sspmv3(file,set,full,index)
	return set

static func _sspmv3(file:FileAccess,set:Mapset,full:bool,index:int=-1):
	file.seek(file.get_position()+2)

	# Metadata
	var id = FileAccess.get_md5(file.get_path())
	set.id = id
	var online_id_length = file.get_8() # Online ID
	if online_id_length > 0: set.online_id = file.get_buffer(online_id_length).get_string_from_ascii()
	var name_length = file.get_16() # Map name
	set.name = file.get_buffer(name_length).get_string_from_utf16()
	var creator_length = file.get_16() # Map creator
	set.creator = file.get_buffer(creator_length).get_string_from_utf16()

	# Audio
	var audio_length = file.get_64()
	if audio_length > 1:
		var audio_buffer = file.get_buffer(audio_length)
		_audio(audio_buffer,set)
	else:
		set.broken = true

	# Cover
	var cover_width = file.get_16()
	if cover_width > 1:
		var cover_height = file.get_16()
		var cover_length = file.get_64()
		var cover_buffer = file.get_buffer(cover_length)
		var image = Image.create_from_data(cover_width,cover_height,false,Image.FORMAT_RGBA8,cover_buffer)
		_cover(image,set)
	else:
		set.broken = true

	# Data
	var indexed = index != -1
	var map_count = file.get_8()
	set.maps = []
	set.maps.resize(map_count)
	for i in range(map_count):
		print("Reading map %s from mapset" % i)
		var map = Map.new()
		var dname_length = file.get_16()
		map.name = file.get_buffer(dname_length).get_string_from_utf16()
		var data_length = file.get_64()
		var data = file.get_buffer(data_length).get_string_from_utf8()
		if full and (!indexed or index == i):
			var hash_ctx = HashingContext.new()
			hash_ctx.start(HashingContext.HASH_MD5)
			map.id = hash_ctx.finish().hex_encode()
			deserialise_v3_data(data,map)
		set.maps[i] = map
static func deserialise_v3_data(data:String,map:Map):
	var parsed = JSON.parse_string(data)
	if parsed.get("version",1) > 1:
		map.unsupported = true
	map.notes = []
	for note_data in parsed.get("notes",[]):
		var note = Map.Note.new()
		note.index = note_data.index
		note.x = note_data.position[0]
		note.y = note_data.position[1]
		note.time = note_data.time
		note.data = note_data
		map.notes.append(note)
	map.data = parsed

static func get_audio_format(buffer:PackedByteArray):
	if buffer.slice(0,4) == PackedByteArray([0x4F,0x67,0x67,0x53]): return Globals.AudioFormat.OGG

	if (buffer.slice(0,4) == PackedByteArray([0x52,0x49,0x46,0x46])
	and buffer.slice(8,12) == PackedByteArray([0x57,0x41,0x56,0x45])): return Globals.AudioFormat.WAV

	if (buffer.slice(0,2) == PackedByteArray([0xFF,0xFB])
	or buffer.slice(0,2) == PackedByteArray([0xFF,0xF3])
	or buffer.slice(0,2) == PackedByteArray([0xFF,0xFA])
	or buffer.slice(0,2) == PackedByteArray([0xFF,0xF2])
	or buffer.slice(0,3) == PackedByteArray([0x49,0x44,0x33])): return Globals.AudioFormat.MP3

	return Globals.AudioFormat.UNKNOWN

static func _cover(image:Image,set:Mapset):
	var texture = ImageTexture.create_from_image(image)
	set.cover = texture
static func _audio(buffer:PackedByteArray,set:Mapset):
	var format = get_audio_format(buffer)
	match format:
		Globals.AudioFormat.WAV:
			var stream = AudioStreamWAV.new()
			stream.data = buffer
			set.audio = stream
		Globals.AudioFormat.OGG:
			var stream = AudioStreamOggVorbis.new()
			stream.packet_sequence = Globals.get_ogg_packet_sequence(buffer)
			set.audio = stream
		Globals.AudioFormat.MP3:
			var stream = AudioStreamMP3.new()
			stream.data = buffer
			set.audio = stream
		_:
			print("I don't recognise this format! %s" % buffer.slice(0,3))
			set.broken = true

static func _sspmv1(file:FileAccess,set:Mapset,full:bool):
	file.seek(file.get_position()+2) # Header reserved space or something
	var map = Map.new()
	set.maps = [map]
	set.id = file.get_line()
	map.id = set.id
	set.name = file.get_line()
	set.song = set.name
	set.creator = file.get_line()
	map.creator = set.creator
	file.seek(file.get_position()+4) # skip last_ms
	var note_count = file.get_32()
	var difficulty = file.get_8()
	map.name = Map.DifficultyNames[difficulty]
	# Cover
	var cover_type = file.get_8()
	match cover_type:
		1:
			var height = file.get_16()
			var width = file.get_16()
			var mipmaps = bool(file.get_8())
			var format = file.get_8()
			var length = file.get_64()
			var image = Image.create_from_data(width,height,mipmaps,format,file.get_buffer(length))
			_cover(image,set)
		2:
			var image = Image.new()
			var length = file.get_64()
			image.load_png_from_buffer(file.get_buffer(length))
			_cover(image,set)
		_:
			set.cover = Map.LegacyCovers.get(difficulty)
	if file.get_8() != 1: # No music
		set.broken = true
		return
	var music_length = file.get_64()
	var music_buffer = file.get_buffer(music_length)
	var music_format = get_audio_format(music_buffer)
	if music_format == Globals.AudioFormat.UNKNOWN:
		set.broken = true
	else:
		_audio(music_buffer,set)
	if not full: return
	map.notes = []
	for i in range(note_count):
		var note = Map.Note.new()
		note.time = float(file.get_32())/1000
		if file.get_8() == 1:
			note.x = file.get_float()
			note.y = file.get_float()
		else:
			note.x = float(file.get_8())
			note.y = float(file.get_8())
		map.notes.append(note)
	map.notes.sort_custom(func(a,b): return a.time < b.time)
	for i in range(map.notes.size()):
		map.notes[i].index = i

static func _read_data_type(file:FileAccess,skip_type:bool=false,skip_array_type:bool=false,type:int=0,array_type:int=0):
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
static func _sspmv2(file:FileAccess,set:Mapset,full:bool):
	var map = Map.new()
	set.maps = [map]
	file.seek(0x26)
	var marker_count = file.get_32()
	var difficulty = file.get_8()
	map.name = Map.DifficultyNames[difficulty]
	file.get_16()
	if !bool(file.get_8()): # Does the map have music?
		map.broken = true
		return
	var cover_exists = bool(file.get_8())
	file.seek(0x40)
	var audio_offset = file.get_64()
	var audio_length = file.get_64()
	var cover_offset = file.get_64()
	var cover_length = file.get_64()
	var marker_def_offset = file.get_64()
	file.seek(0x70)
	var markers_offset = file.get_64()
	file.seek(0x80)
	set.id = file.get_buffer(file.get_16()).get_string_from_utf8()
	map.id = set.id
	set.name = file.get_buffer(file.get_16()).get_string_from_utf8()
	set.song = file.get_buffer(file.get_16()).get_string_from_utf8()
	set.creator = ""
	for i in range(file.get_16()):
		var creator = file.get_buffer(file.get_16()).get_string_from_utf8()
		if i != 0:
			set.creator += " & "
		set.creator += creator
	map.creator = set.creator
	for i in range(file.get_16()):
		var key_length = file.get_16()
		var key = file.get_buffer(key_length).get_string_from_utf8()
		var value = _read_data_type(file)
		if key == "difficulty_name" and typeof(value) == TYPE_STRING:
			map.name = str(value)
	# Cover
	if cover_exists:
		file.seek(cover_offset)
		var image = Image.new()
		image.load_png_from_buffer(file.get_buffer(cover_length))
		_cover(image,set)
	else:
		set.cover = Map.LegacyCovers.get(difficulty)
	# Audio
	file.seek(audio_offset)
	_audio(file.get_buffer(audio_length),set)
	if not full: return
	# Markers
	file.seek(marker_def_offset)
	var markers = {}
	var types = []
	for _i in range(file.get_8()):
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
		markers[type[0]].append(marker)
	if !markers.has("ssp_note"):
		map.broken = true
		return
	map.notes = []
	for note_data in markers.get("ssp_note"):
		if note_data[1] != 7: continue
		var note = Map.Note.new()
		note.time = float(note_data[0])/1000
		note.x = note_data[2].x
		note.y = note_data[2].y
		map.notes.append(note)
	map.notes.sort_custom(func(a,b): return a.time < b.time)
	for i in range(map.notes.size()):
		map.notes[i].index = i
