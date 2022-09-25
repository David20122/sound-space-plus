extends Resource
class_name Song

signal downloaded

var id:String
var name:String
var creator:String

var difficulty:int = Globals.DIFF_UNKNOWN


var rawData:String = ""
var notes:Array
var note_count:int
var musicFile:String = ""
var last_ms:float = 0
var source_registry:String = "[unknown]"
var warning:String = ""

var should_reload_on_play:bool = false
var songType:int = -1
var initFile:String = ""

var filePath:String

var cover:Texture setget , _get_cover
var has_cover:bool = false
var is_broken:bool = false
var converted:bool = false

var is_builtin:bool = false

var is_online:bool = false
var download_url:String = ""

var sspm_song_stored:bool = false

var pbs_loaded:bool = false
var pb_data:Dictionary = {}

func _get_cover():
	return cover
	# I'll eventually add handling for online maps with covers

func is_valid_id(txt:String):
	return !(
		(txt.to_lower() != txt) or 
		(txt.length() == 0) or 
		txt.begins_with("_") or 
		!(("n" + txt).replace("-","")).is_valid_identifier()
	)

func load_from_db_data(data:Dictionary={
		"id":"INVALID_id_that_doesnt_exist",
		"download":"http://chedski.test/ssp/mapdb/api/download/INVALID_id_that_doesnt_exist",
		"audio":"http://chedski.test/ssp/mapdb/api/audio/INVALID_id_that_doesnt_exist",
#		"id":"ss_archive_waterflame_-_geometrical_dominator",
#		"download":"http://chedski.test/ssp/mapdb/api/download/ss_archive_waterflame_-_geometrical_dominator",
#		"audio":"http://chedski.test/ssp/mapdb/api/audio/ss_archive_waterflame_-_geometrical_dominator",
		"cover":null,
		"version":1,
		"name":"000000 net test map",
		"song":"Waterflame - Geometrical Dominator",
		"author":["Azurlexx"],
		"difficulty":3,
		"difficulty_name":"LOGIC?",
		"stars":-1,
		"length_ms":96846,
		"note_count":384,
		"has_cover":false,
		"broken":false,
		"tags":["ss_archive"],
		"content_warnings":[],
		"note_data_offset":1594212,
		"note_data_length":2688,
		"music_format":"mp3",
		"music_offset":117,
		"music_length":1594095
	}):
	
	if !data.has("id"): return {success=false,error="014-421"}
	if !data.has("name"): return {success=false,error="014-422"}
	if !data.has("author"): return {success=false,error="014-423"}
	if !data.has("version"): return {success=false,error="014-594"}
	if !data.has("difficulty"): return {success=false,error="014-424"}
	if !data.has("length_ms"): return {success=false,error="014-425"}
	if !data.has("note_count"): return {success=false,error="014-426"}
	if !data.has("download"): return {success=false,error="014-415"}
	
	if typeof(data.id) != TYPE_STRING: return {success=false,error="014-462"}
	if typeof(data.name) != TYPE_STRING: return {success=false,error="014-463"}
	if typeof(data.author) != TYPE_ARRAY: return {success=false,error="014-464"}
	if typeof(data.difficulty) != TYPE_INT and typeof(data.difficulty) != TYPE_REAL: return {success=false,error="014-465"}
	if typeof(data.version) != TYPE_INT and typeof(data.version) != TYPE_REAL: return {success=false,error="014-595"}
	if typeof(data.length_ms) != TYPE_INT and typeof(data.length_ms) != TYPE_REAL: return {success=false,error="014-466"}
	if typeof(data.note_count) != TYPE_INT and typeof(data.note_count) != TYPE_REAL: return {success=false,error="014-467"}
	if typeof(data.download) != TYPE_STRING or !Globals.is_valid_url(data.download): return {success=false,error="014-418"}
	
	if !is_valid_id(data.id): return {success=false,error="014-461"}
	if data.difficulty < -1 or data.difficulty > 4: return {success=false,error="014-465"}
	
	id = data.id
	name = data.name
	var authorstr = ""
	for a in data.author:
		if a != data.author[0]: authorstr += " & "
		authorstr += a
	creator = authorstr
	difficulty = int(data.difficulty)
	last_ms = float(data.length_ms)
	note_count = int(data.note_count)
	download_url = data.download
	is_online = true
	
	return {success=true}

func load_pbs():
	var file:File = File.new()
	if file.file_exists(Globals.p("user://bests/%s" % id)):
		var err:int = file.open(Globals.p("user://bests/%s" % id),File.READ)
		if err != OK:
#			print("error reading pb file for %s: %s" % [id, String(err)])
			return
		
		if file.get_buffer(5) != PoolByteArray([0x53,0x53,0x2B,0x70,0x42]):
			print("invalid signature for pb file (%s)" % id)
			file.close()
			return
		
		var sv:int = file.get_16()
		if sv > 2:
			print("invalid file version for pb file (%s)" % id)
			file.close()
			return
		
		var amt:int = file.get_64() # number of bests stored
		
		for i in range(amt):
			var pb:Dictionary = {}
			var s:String = file.get_line()
			if sv == 1: s = s.replace("1.27","1.14") # handle the default hitbox change
			pb.has_passed = bool(file.get_8())
			pb.pauses = file.get_16()
			pb.hit_notes = file.get_32()
			pb.total_notes = file.get_32()
			pb.position = file.get_32()
			pb.length = file.get_32()
			pb_data[s] = pb
		file.close()

func save_pbs():
	var file:File = File.new()
	var err:int = file.open(Globals.p("user://bests/%s") % id,File.WRITE)
	if err != OK:
		print("error writing pb file for %s: %s" % [id, String(err)])
		return
	file.store_buffer(PoolByteArray([0x53,0x53,0x2B,0x70,0x42]))
	file.store_16(2) # version
	file.store_64(pb_data.size()) # number of PBs
	for k in pb_data.keys():
		var pb:Dictionary = pb_data[k]
		file.store_line(k)
		file.store_8(int(pb.has_passed))
		file.store_16(pb.pauses)
		file.store_32(pb.hit_notes)
		file.store_32(pb.total_notes)
		
		# prevent the 69420:00 bug (hacky but it should work)
		if pb.has_passed: file.store_32(floor(pb.length))
		else: file.store_32(floor(min(pb.length,pb.position)))
		
		file.store_32(floor(pb.length))
	file.close()

func get_pb(pb_str:String):
	if !pbs_loaded: load_pbs()
	return pb_data.get(pb_str,{})

func is_pb_better(ob:Dictionary,pb:Dictionary):
	# ensure everything exists on ob
	ob.has_passed = ob.get("has_passed",false)
	ob.total_notes = ob.get("total_notes",4294967295)
	ob.hit_notes = ob.get("hit_notes",0)
	ob.pauses = ob.get("pauses",65535)
	ob.position = ob.get("position",0)
	ob.length = ob.get("length",1)
	
	if int(pb.has_passed) < int(ob.has_passed): return false # pass -> fail
	elif int(pb.has_passed) > int(ob.has_passed): return true # fail -> pass
	
	if !pb.has_passed:
		if pb.position > ob.position: return true # made more progress
		elif pb.position < ob.position: return false # made less progress
	var pbm = pb.total_notes - pb.hit_notes
	var obm = ob.total_notes - ob.hit_notes
	
	if pbm < obm: return true # fewer misses
	elif pbm > obm: return false # more misses
	
	if pb.pauses < ob.pauses: return true # fewer pauses
	elif pb.pauses > ob.pauses: return false # more pauses

func set_pb_if_better(pb_str:String,pb:Dictionary):
	if !pbs_loaded: load_pbs()
	var ob:Dictionary = get_pb(pb_str)
	
	if is_pb_better(ob,pb):
		pb_data[pb_str] = pb
		save_pbs()
		return true
	else: return false

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
		
		var ct = file.get_8()
		if ct == 1: # Skip over cover
			file.seek(file.get_position() + 6)
			var clen = file.get_64()
			file.seek(file.get_position() + clen)
		elif ct == 2:
			var clen = file.get_64()
			file.seek(file.get_position() + clen)
		
		if file.get_8() != 1:
			file.close()
			return Globals.error_sound
		
		var blen:int = file.get_64()
		var buf:PoolByteArray = file.get_buffer(blen) # Actual song data
		var s = Globals.audioLoader.load_buffer(buf)
		file.close()
		if s is AudioStreamOGGVorbis or s is AudioStreamMP3: s.loop = false
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
	initFile = path
	var file:File = File.new()
	var err = file.open(path,File.READ)
	if err != OK:
		warning = "[txt map] File could not be opened - returned error " + String(err)
		return
	rawData = file.get_as_text()
	file.close()

func loadRawData(data:String):
	rawData = data
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
	else:
		warning = ""
		is_broken = false
	note_count = notes.size()

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
	if songFile.begins_with("res://") or mapFile.begins_with("res://"):
		is_builtin = true
	loadFromFile(mapFile)
	if rawData: loadRawData(rawData)
	return self

func setup_from_data(mapData:String,songFile:String):
	songType = Globals.MAP_RAW
	musicFile = songFile
	if songFile.begins_with("res://"):
		is_builtin = true
	loadRawData(mapData)
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

func notesort(a,b):
	if a[2] == b[2]:
		if a[1] == b[1]: return a[0] < b[0]
		return a[1] < b[1]
	return a[2] < b[2]

func read_notes() -> Array:
	if songType == Globals.MAP_TXT:
		discard_notes()
	if notes.size() == 0:
		if (songType == Globals.MAP_RAW or songType == Globals.MAP_TXT):
			print("RAW/TXT")
			if songType == Globals.MAP_TXT:
				print("TXT")
				loadFromFile(initFile)
			else: print(rawData)
			loadRawData(rawData)
			print(notes.size())
			return notes
		elif songType == Globals.MAP_VULNUS:
#			print("VULNUS")
			var file = File.new()
			file.open(filePath,File.READ)
#			print(filePath)
			var json = file.get_as_text()
			file.close()
			var data:Dictionary = parse_json(json)
#			print(data.has("_notes"))
			var n:Array = data.get("_notes",[])
#			print(n.size())
			loadVulnusNoteArray(n)
			return notes
		elif songType == Globals.MAP_SSPM:
#			print("SSPM")
			var file:File = File.new()
			var err = file.open(filePath,File.READ)
			if err != OK:
				print("error opening file")
				return []
			
			file.seek(8) # Skip over header data
			file.get_line() # Skip over metadata
			file.get_line()
			file.get_line()
			file.seek(file.get_position() + 4)
			note_count = file.get_32()
			file.seek(file.get_position() + 1)
			
			var ct = file.get_8()
			if ct == 1: # Skip over cover
				file.seek(file.get_position() + 6)
				var clen = file.get_64()
				file.seek(file.get_position() + clen)
			elif ct == 2:
				var clen = file.get_64()
				file.seek(file.get_position() + clen)
			
			if file.get_8() != 1:
				print("no music?")
#				file.close()
#				return []
			else:
				file.seek(file.get_position() + file.get_64() + 8) # Skip over music
			
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
				
			file.close()
	
	return notes

func discard_notes():
	if songType != Globals.MAP_RAW:
		notes = []
		rawData = "" 

func change_difficulty(to:int):
	if songType != Globals.MAP_SSPM: 
		print("tried to change difficulty of a non .sspm map")
		return ERR_UNAVAILABLE
	else:
		if Globals.difficulty_names.get(to,null) == null:
			print("invalid difficulty")
			return ERR_INVALID_PARAMETER
		
		var file:File = File.new()
		var err = file.open(filePath,File.READ_WRITE)
		if err != OK:
			print("file open failed: ",err)
			return err
		
		if file.get_buffer(4) != PoolByteArray([0x53,0x53,0x2b,0x6d]): # signature
			print("invalid sspm file")
			return ERR_INVALID_DATA
		
		if file.get_16() > 2 or file.get_16() != 0: # version, reserved header
			print("invalid version or reserved header")
			return ERR_INVALID_DECLARATION
		
		file.get_line() # id
		file.get_line() # name
		file.get_line() # creator
		file.seek(file.get_position() + 8) # skip over map length and note count
		
		difficulty = to
		file.store_8(difficulty + 1)
		file.close()
		return OK

func convert_to_sspm():
	var file:File = File.new()
	var dir:Directory = Directory.new()
	# Figure out the path and make sure it's usable
	var path:String = Globals.p("user://maps/%s.sspm") % id
	if !dir.dir_exists(Globals.p("user://maps")): dir.make_dir(Globals.p("user://maps"))
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
	if notes.size() != 0:
		last_ms = notes[notes.size()-1][2]
	else: last_ms = 0
	file.store_32(last_ms) # Map length
	file.store_32(note_count) # Map note count
	file.store_8(difficulty + 1)
	
	var file2:File = File.new()
	# Cover
	if has_cover and cover and (cover.get_height() + cover.get_width()) >= 9:
		file.store_8(2)
		var img:Image = cover.get_data()
#		file.store_16(img.get_height()) # Height
#		file.store_16(img.get_width()) # Width
#		file.store_8(int(img.has_mipmaps())) # Has mipmaps
#		file.store_8(img.get_format()) # Image format
		var data:PoolByteArray = img.save_png_to_buffer()
		file.store_64(data.size()) # Buffer length in bytes
		file.store_buffer(data) # Actual cover data
	else: file.store_8(0)
	
	# Audio
	if songType == Globals.MAP_SSPM:
		err = file2.open(filePath,File.READ)
		if err == OK:
			file2.seek(8) # Skip over header data
			file2.get_line() # Skip over metadata
			file2.get_line()
			file2.get_line()
			file2.seek(file2.get_position() + 9)
			
			var ct = file2.get_8()
			if ct == 1: # Skip over cover
				file.seek(file2.get_position() + 6)
				var clen = file2.get_64()
				file2.seek(file2.get_position() + clen)
			elif ct == 2:
				var clen = file2.get_64()
				file2.seek(file2.get_position() + clen)
			
			if file2.get_8() != 1:
				file2.close()
				file.store_8(0)
				push_warning("no music present")
			else:
				var blen:int = file2.get_64()
				var buf:PoolByteArray = file2.get_buffer(blen) # Actual song data
				
				file.store_8(1)
				file2.close()
				file.store_64(buf.size())
				file.store_buffer(buf)
		else:
			file.store_8(0)
			push_warning("err was %s" % err)
	else:
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
	is_online = false
	songType = Globals.MAP_SSPM
	filePath = path
	musicFile = path
	if path.begins_with("res://"):
		is_builtin = true
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
	var ct = file.get_8()
	if ct == 1 or ct == 2:
		var img:Image = Image.new()
		if ct == 1:
			var h:int = file.get_16()
			var w:int = file.get_16()
			var mip:bool = bool(file.get_8())
			var format:int = file.get_8()
			var clen:int = file.get_64()
			var cbuf:PoolByteArray = file.get_buffer(clen)
			img.create_from_data(w,h,mip,format,cbuf)
		elif ct == 2:
			var clen:int = file.get_64()
			var cbuf:PoolByteArray = file.get_buffer(clen)
			img.load_png_from_buffer(cbuf)
		
		var imgtex:ImageTexture = ImageTexture.new()
		imgtex.create_from_image(img)
		cover = imgtex
		has_cover = true
	
	if file.get_8() != 1:
		warning = "[sspm] Invalid music storage type!"
		is_broken = true
		file.close()
		return
	else:
		file.get_64()
		var buf:PoolByteArray = file.get_buffer(12)
		if Globals.audioLoader.get_format(buf) == "unknown":
			warning = "[sspm] Invalid music data!"
			is_broken = true
			file.close()
			return
	
	sspm_song_stored = true
	
	file.close() # All done!
	return self

func export_text(path:String):
	var txt = id + ","
	var notearr:Array = read_notes()
	if notearr.size() == 0:
		return "no notes"
	else:
		for n in read_notes():
			txt += "%s|%s|%s," % n

	var file:File = File.new()
	var err:int = file.open(path,File.WRITE)
	if err != OK: return "file.open errored - code " + String(err)
	file.store_string(txt.trim_suffix(","))
	file.close()
	return "OK"

func _init(idI:String="SOMETHING IS VERY BROKEN",nameI:String="SOMETHING IS VERY BROKEN",creatorI:String="Unknown"):
	id = idI
	name = nameI
	creator = creatorI











