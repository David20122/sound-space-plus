extends Resource
class_name Song

var id:String
var name:String
var creator:String

var difficulty:int = Globals.DIFF_UNKNOWN

var rawData:String
var notes:Array
var note_count:int
var musicFile:String
var last_ms:float = 0
var source_registry:String = "[unknown]"
var warning:String = ""

var should_reload_on_play:bool = false
var songType:int
var initFile:String

var filePath:String

var cover:Texture
var has_cover:bool = false
var is_broken:bool = false
var converted:bool = false

var sspm_song_stored:bool = false

func stream() -> AudioStream:
	if sspm_song_stored:
		var file:File = File.new()
		var err = file.open(filePath,File.READ)
		if err != OK: return Globals.error_sound
		
		file.seek(8) # Skip over header data
		file.get_line() # Skip over metadata
		file.get_line()
		file.get_line()
		file.seek(file.get_position() + 9)
		
		if file.get_8() != 0: # Skip over cover
			file.seek(file.get_position() + 6)
			var clen = file.get_64()
			file.seek(file.get_position() + clen)
		if file.get_8() != 1: return Globals.error_sound
		
		var blen:int = file.get_64()
		var buf:PoolByteArray = file.get_buffer(blen) # Actual song data
		var s = Globals.audioLoader.load_buffer(buf)
		if s: return s
		else: return Globals.error_sound
	elif !musicFile.begins_with("res://"):
		var stream = Globals.audioLoader.load_file(musicFile)
		if stream: return stream
		else: return Globals.error_sound
	else: 
		var mf:AudioStream = load(musicFile) as AudioStream
		if mf is AudioStreamOGGVorbis or mf is AudioStreamMP3: mf.loop = false
		elif mf is AudioStreamSample: mf.loop_mode = AudioStreamSample.LOOP_DISABLED
		return mf

func loadFromFile(path:String):
	var file:File = File.new()
	var err = file.open(path,File.READ)
	if err != OK:
		warning = "[txt map] File could not be opened - returned error " + String(err)
		return
	rawData = file.get_as_text()
	file.close()

func loadRawData(data:String):
	rawData = data
#	var songPath:String = path.replace("txt","oga")
#	if !file.file_exists(songPath): songPath = path.replace("txt","ogg")
#	if !file.file_exists(songPath): songPath = path.replace("txt","mp3")
#	var song:AudioStream = load(songPath)
#	if song is AudioStreamMP3: song.loop = false
#	if song is AudioStreamOGGVorbis: song.loop = false
	var blank = 0
	var invalid = 0
	var split:Array = rawData.split(",")
	split.remove(0)
	notes = []
	for s in split:
		if s != "":
			var dat = s.split("|")
			if (dat is Array or dat is PoolStringArray) and dat.size() == 3:
				var x = 2 - float(dat[0])
				var y = 2 - float(dat[1])
				var ms = float(dat[2])
				last_ms = ms
				notes.append([x,y,ms])
			else: invalid += 1
		else: blank += 1
	var file = File.new()
	if !file.file_exists(musicFile) and !musicFile.begins_with("res://"):
		warning = "[txt map] Audio file doesn't exist!"
		is_broken = true
	elif invalid != 0: warning = "[txt map] Song has %s invalid note(s)" % String(invalid)
	elif blank != 0: warning = "[txt map] Song has %s blank note(s)" % String(blank)
	note_count = notes.size()
#	get_node("Spawn/Music").stream = song
#	$Spawn.spawn_notes(notes)

func loadVulnusNoteArray(vNotes:Array):
	notes = []
	var invalid = 0
	for n in vNotes:
		if n.get("_time") != null and n.get("_x") != null and n.get("_y") != null:
			var ms = n._time*1000
			var x = 2 - (n._x + 1)
			var y = 2 - (n._y + 1)
			last_ms = ms
			notes.append([x,y,ms])
		else: invalid += 1
	var file = File.new()
	if !file.file_exists(musicFile) and !musicFile.begins_with("res://"):
		warning = "[vulnus map] Audio file doesn't exist!"
		is_broken = true
	elif invalid != 0: warning = "[vulnus map] Song has %s invalid note(s)" % String(invalid)
	note_count = notes.size()

func setup_from_file(mapFile:String,songFile:String):
	songType = Globals.MAP_TXT
	initFile = mapFile
	musicFile = songFile
	loadFromFile(mapFile)
	if rawData: loadRawData(rawData)
	return self

func setup_from_data(mapData:String,songFile:String):
	songType = Globals.MAP_RAW
	musicFile = songFile
	loadRawData(mapData)
	discard_notes()
	return self

func setup_from_vulnus_json(jsonPath:String,songFile:String):
	print("PARSING VULNUS JSON: " + jsonPath)
	songType = Globals.MAP_VULNUS
	musicFile = songFile
	filePath = jsonPath
	var file = File.new()
	file.open(jsonPath,File.READ)
	var json = file.get_as_text()
	file.close()
	note_count = json.count('"_time"')
	if note_count != 0:
		var last = json.find_last('"_time":')
		print(last)
		var comma = json.find(",",last)
		var time_str:String = json.substr(last+8,comma-last-8).trim_prefix(" ")
		if !time_str.is_valid_float():
			warning = "[vulnus map] Couldn't read final timestamp!"
			is_broken = true
			return self
		var ms = float(time_str)*1000
		last_ms = ms
		return self
	else:
		warning = "[vulnus map] Song has no notes!"
		is_broken = true
		return self

func read_notes() -> Array:
	if notes.size() == 0:
		if (songType == Globals.MAP_RAW or songType == Globals.MAP_TXT):
			if songType == Globals.MAP_TXT:
				loadFromFile(initFile)
			loadRawData(rawData)
		elif songType == Globals.MAP_VULNUS:
			var file = File.new()
			file.open(filePath,File.READ)
			var json = file.get_as_text()
			file.close()
			var data:Dictionary = parse_json(json)
			loadVulnusNoteArray(data.get("_notes",[]))
		elif songType == Globals.MAP_SSPM:
			var file:File = File.new()
			var err = file.open(filePath,File.READ)
			if err != OK: return []
			
			file.seek(8) # Skip over header data
			file.get_line() # Skip over metadata
			file.get_line()
			file.get_line()
			file.seek(file.get_position() + 6)
			note_count = file.get_32()
			file.seek(file.get_position() + 1)
			
			if file.get_8() != 0: # Skip over cover
				file.seek(file.get_position() + 6)
				file.seek(file.get_position() + file.get_64())
			
			if file.get_8() != 1: return []
			file.seek(file.get_position() + file.get_64()) # Skip over music
			
			# Note data
			for i in range(note_count):
				var n = [0,0,-1]
				n[2] = file.get_32()
				if file.get_8() == 1:
					# Note is off-grid (Quantum!)
					n[0] = file.get_float()
					n[1] = file.get_float()
				else:
					# Note is on-grid (boring and unfun)
					n[0] = float(file.get_8())
					n[1] = float(file.get_8())
				notes.append(n)
			
	return notes

func discard_notes():
	notes = []
	if songType == Globals.MAP_TXT:
		rawData = ""

func convert_to_sspm():
	var file:File = File.new()
	var dir:Directory = Directory.new()
	# Figure out the path and make sure it's usable
	var path:String = "user://maps/%s.sspm" % id
	if !dir.dir_exists("user://maps"): dir.make_dir("user://maps")
	if file.file_exists(path): return "File already exists!"
	# Open the file for writing
	var err = file.open(path,File.WRITE)
	if err != OK: return "file.open errored - code " + String(err)
	
	# Header
	file.store_buffer(PoolByteArray([0x53,0x53,0x2b,0x6d])) # File signature
	file.store_16(1) # File type version
	file.store_16(0) # Reserved for future things
	
	# General metadata
	file.store_line(id) # Song ID
	file.store_line(name) # Song name
	file.store_line(creator) # Song name
	
	# Map metadata
	var notes:Array = read_notes()
	note_count = notes.size()
	last_ms = notes[notes.size()-1][2]
	file.store_32(last_ms) # Map length
	file.store_32(note_count) # Map note count
	file.store_8(difficulty + 1)
	
	# Cover
	if cover and (cover.get_height() + cover.get_width()) >= 9:
		file.store_8(1)
		var img:Image = cover.get_data()
		file.store_16(img.get_height()) # Height
		file.store_16(img.get_width()) # Width
		file.store_8(int(img.has_mipmaps())) # Has mipmaps
		file.store_8(img.get_format()) # Image format
		var data:PoolByteArray = img.get_data()
		file.store_64(data.size()) # Buffer length in bytes
		file.store_buffer(data) # Actual cover data
	else: file.store_8(0)
	
	# Audio
	if stream() != Globals.error_sound:
		var file2:File = File.new()
		err = file2.open(musicFile,File.READ)
		if err != OK:
			file.store_8(0)
			push_warning("Failed to open music file while converting map!")
		else:
			var mdata:PoolByteArray = file2.get_buffer(file2.get_len())
			file.store_8(1)
			file2.close()
			file.store_64(mdata.size())
			file.store_buffer(mdata)
	else: file.store_8(0)
	
	# Note data
	for n in notes:
		file.store_32(floor(n[2]))
		if floor(n[0]) != n[0] or floor(n[1]) != n[1]:
			file.store_8(1)
			file.store_float(n[0])
			file.store_float(n[1])
		else:
			file.store_8(0)
			file.store_8(n[0])
			file.store_8(n[1])
	
	file.close() # All done! No need for an external converter, unlike Vulnus :3
	converted = true
	return "Converted!"

func load_from_sspm(path:String):
	songType = Globals.MAP_SSPM
	filePath = path
	musicFile = path
	var file:File = File.new()
	# Open the file for reading
	var err = file.open(path,File.READ)
	if err != OK: return "file.open errored - code " + String(err)
	
	# Header
	if file.get_buffer(4) != PoolByteArray([0x53,0x53,0x2b,0x6d]): return "File is not a valid .sspm (or header is borked)"
	if file.get_16() != 1: return "Unknown .sspm version (update your game?)"
	if file.get_16() != 0: return "Header reserved space is invalid (modded map?)"
	
	id = file.get_line()
	name = file.get_line()
	creator = file.get_line()
	
	# Map metadata
	last_ms = file.get_32()
	note_count = file.get_32()
	difficulty = file.get_8() - 1
	
	# Cover
	if file.get_8() == 1:
		var h:int = file.get_16()
		var w:int = file.get_16()
		var mip:bool = bool(file.get_8())
		var format:int = file.get_8()
		var clen:int = file.get_64()
		var cbuf:PoolByteArray = file.get_buffer(clen)
		var img:Image = Image.new()
		img.create_from_data(w,h,mip,format,cbuf)
		var imgtex:ImageTexture = ImageTexture.new()
		imgtex.create_from_image(img)
		cover = imgtex
		has_cover = true
	
	if file.get_8() != 1:
		warning = "[sspm] Invalid music storage type!"
		is_broken = true
		return
	
	sspm_song_stored = true
	
	file.close() # All done!
	return self

func _init(idI:String="SOMETHING IS VERY BROKEN",nameI:String="SOMETHING IS VERY BROKEN",creatorI:String="Unknown"):
	id = idI
	name = nameI
	creator = creatorI











