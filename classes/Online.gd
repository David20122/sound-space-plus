extends Node

var mapdb_api:String = ""

var map_registry:Registry

signal db_maps_done
signal map_downloaded

signal _httpreq_finished

var mapdl_hr:HTTPRequest = HTTPRequest.new()
var mapdl_bs:float = 1
var mapdl_bd:float = 0

signal _mapdl_req
func _on_mapdl_request_completed(result:int,response_code:int,headers:PoolStringArray,body:PoolByteArray):
	emit_signal("_mapdl_req",{result=result,response_code=response_code,headers=headers,body=body})

func cancel():
	mapdl_hr.cancel_request()
	emit_signal("_mapdl_req",{result=-1})

func mapdl_error(id:String,error:String,map:Song):
	print("[MapDB Download] Map %s errored with code %s" % [map.id,error])
	emit_signal("map_downloaded",{id=id, success=false, error=error})

func _process(_d):
	mapdl_bs = mapdl_hr.get_body_size()
	mapdl_bd = mapdl_hr.get_downloaded_bytes()

signal _connection_test
var ctest_hr:HTTPRequest = HTTPRequest.new()
func _on_ctest_request_completed(result:int,response_code:int,headers:PoolStringArray,body:PoolByteArray):
	if result == HTTPRequest.RESULT_SUCCESS:
		emit_signal("_connection_test",true)
	else:
		emit_signal("_connection_test",false)

func test_connection():
	var res = ctest_hr.request(ProjectSettings.get_setting("application/networking/test_url"))
	if res != OK: emit_signal("_connection_test",false)

func _mapdl_handler(id:String,map:Song):
	print("[MapDB Download] Starting download of map %s" % map.id)
	if !ProjectSettings.get_setting("application/networking/enabled"):
		mapdl_error(id,"011-865",map); return
	if mapdb_api == "":
		mapdl_error(id,"011-925",map); return
	if !Globals.is_valid_url(mapdb_api):
		mapdl_error(id,"011-928",map); return
	
	call_deferred("test_connection")
	if !yield(self,"_connection_test"):
		mapdl_error(id,"011-140",map); return
	
	var dir:Directory = Directory.new()
	if dir.file_exists(Globals.p("user://mapdl.sspm.part")):
		dir.remove(Globals.p("user://mapdl.sspm.part"))
	
	mapdl_hr.download_file = Globals.p("user://mapdl.sspm.part")
	var res = mapdl_hr.request(map.download_url)
	if res != OK:
		if res == ERR_INVALID_PARAMETER: mapdl_error(id,"011-928",map)
		elif res == ERR_CANT_CONNECT: mapdl_error(id,"011-252",map)
		else: mapdl_error(id,"011-339",map)
	else:
		var mapdl_res = yield(self,"_mapdl_req")
		
		if mapdl_res.result == HTTPRequest.RESULT_CANT_RESOLVE:
			mapdl_error(id,"011-240",map)
		elif mapdl_res.result == HTTPRequest.RESULT_CANT_CONNECT:
			mapdl_error(id,"011-250",map)
		elif mapdl_res.result == HTTPRequest.RESULT_CONNECTION_ERROR:
			mapdl_error(id,"011-251",map)
		elif mapdl_res.result == HTTPRequest.RESULT_SSL_HANDSHAKE_ERROR:
			mapdl_error(id,"012-220",map)
		elif mapdl_res.result == HTTPRequest.RESULT_TIMEOUT:
			mapdl_error(id,"012-240",map)
		elif mapdl_res.result == HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED:
			mapdl_error(id,"012-545",map)
		elif mapdl_res.result == HTTPRequest.RESULT_DOWNLOAD_FILE_CANT_OPEN:
			mapdl_error(id,"013-220",map)
		elif mapdl_res.result == HTTPRequest.RESULT_DOWNLOAD_FILE_WRITE_ERROR:
			mapdl_error(id,"013-320",map)
			
		elif mapdl_res.result == HTTPRequest.RESULT_SUCCESS:
			if mapdl_res.response_code == 200:
				dir.rename(Globals.p("user://mapdl.sspm.part"),Globals.p("user://maps/%s.sspm" % map.id))
				map.load_from_sspm(Globals.p("user://maps/%s.sspm" % map.id))
				emit_signal("map_downloaded",{id=id, success=true})
			else:
				var resp = parse_json(mapdl_res.body.get_string_from_utf8())
				if resp: mapdl_error(id, resp.error, map)
				else: mapdl_error(id, "023-%s" % mapdl_res.response_code, map)
		elif mapdl_res.result == -1: # cancelled
			mapdl_error(id,"010-100", map)
		else: # Unknown error
			mapdl_error(id,"012-600", map)


func download_map(map:Song):
	var id = v4()
	call_deferred("_mapdl_handler",id,map)
	return id


var netmaps_hr:HTTPRequest = HTTPRequest.new()
signal _netmaps_req
func _on_netmaps_request_completed(result:int,response_code:int,headers:PoolStringArray,body:PoolByteArray):
	emit_signal("_netmaps_req",{result=result,response_code=response_code,headers=headers,body=body})

func load_db_maps():
	yield(get_tree(),"idle_frame")
	
	if !ProjectSettings.get_setting("application/networking/enabled"):
		pass # 011-865
	elif mapdb_api == "":
		pass # 011-925
	elif !Globals.is_valid_url(mapdb_api):
		show_db_error("Map database download failed.\nError code: 011-928","Map Database Error")
		yield(self,"error_done")
	else:
		call_deferred("test_connection")
		if !yield(self,"_connection_test"):
			Globals.notify(
				Globals.NOTIFY_ERROR,
				"Not loading online maps as internet seems to be disconnected",
				"No Connection"
			)
			emit_signal("db_maps_done")
			return
		
		var netmaps:Dictionary = {
			"id_that_doesnt_exist": parse_json("""{
				"id":"id_that_doesnt_exist",
				"download":"http://chedski.test/ssp/mapdb/api/download/id_that_doesnt_exist",
				"audio":"http://chedski.test/ssp/mapdb/api/audio/id_that_doesnt_exist",
				"cover":null,
				"version":1,
				"name":"000000 net test map",
				"song":"Waterflame - Geometrical Dominator",
				"author":["Azurlexx"],
				"difficulty":-1,
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
				"music_length":1594095 }""")
		}
		
		print(mapdb_api+"all")
		netmaps_hr.request(mapdb_api+"all")
		var netmaps_res = yield(self,"_netmaps_req")
		
		if netmaps_res.result == HTTPRequest.RESULT_CANT_RESOLVE:
			show_db_error("Map database download failed.\nError code: 011-240","Map Database Error")
			yield(self,"error_done")
		elif netmaps_res.result == HTTPRequest.RESULT_CANT_CONNECT:
			show_db_error("Map database download failed.\nError code: 011-250","Map Database Error")
			yield(self,"error_done")
		elif netmaps_res.result == HTTPRequest.RESULT_CONNECTION_ERROR:
			show_db_error("Map database download failed.\nError code: 011-251","Map Database Error")
			yield(self,"error_done")
		elif netmaps_res.result == HTTPRequest.RESULT_SSL_HANDSHAKE_ERROR:
			show_db_error("Map database download failed.\nError code: 012-220","Map Database Error")
			yield(self,"error_done")
		elif netmaps_res.result == HTTPRequest.RESULT_TIMEOUT:
			show_db_error("Map database download failed.\nError code: 012-240","Map Database Error")
			yield(self,"error_done")
		elif netmaps_res.result == HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED:
			show_db_error("Map database download failed.\nError code: 012-545","Map Database Error")
			yield(self,"error_done")
			
		elif netmaps_res.result == HTTPRequest.RESULT_SUCCESS:
			if netmaps_res.response_code == 200:
				var nmp = parse_json(netmaps_res.body.get_string_from_utf8())
				if !(nmp is Dictionary):
					show_db_error("Map database download failed.\nError code: 014-905","Map Database Error")
					yield(self,"error_done")
				else:
					netmaps = nmp
					var i = 0
					for id in netmaps.keys():
						if !map_registry.idx_id.has(id):
							var song:Song = Song.new()
							var res:Dictionary = song.load_from_db_data(netmaps[id])
							
							if res.success:
								map_registry.add_item(song)
							else:
								print("[MapDB Import] Map %s errored with code %s" % [id,res.error])
								Globals.notify(
									Globals.NOTIFY_ERROR,
									"map %s errored\nError code: %s" % [id,res.error],
									"Map Database Import"
								)
							
							i += 1
							if fmod(i,floor(float(netmaps.size())/100)) == 0: yield(get_tree(),"idle_frame")
			else:
				show_db_error("Map database download failed.\nError code: 023-%s" % netmaps_res.response_code,"Map Database Error")
				yield(self,"error_done")
		else: # Unknown error
			show_db_error("Map database download failed.\nError code: 012-600","Map Database Error")
			yield(self,"error_done")
			
	
	emit_signal("db_maps_done")

func _ready():
	add_child(netmaps_hr)
	netmaps_hr.use_threads = true
	netmaps_hr.timeout = 80
	netmaps_hr.connect("request_completed",self,"_on_netmaps_request_completed")
	
	add_child(ctest_hr)
	ctest_hr.use_threads = true
	ctest_hr.timeout = 5
	ctest_hr.connect("request_completed",self,"_on_ctest_request_completed")
	
	add_child(mapdl_hr)
	mapdl_hr.use_threads = false
	mapdl_hr.timeout = 0
	mapdl_hr.connect("request_completed",self,"_on_mapdl_request_completed")
	
	pause_mode = PAUSE_MODE_PROCESS
	
	mapdb_api = ProjectSettings.get_setting("application/networking/mapdb_api")

signal error_done
func show_db_error(body:String,title:String):
	# Globals.notify(Globals.NOTIFY_ERROR,title,body)
	Globals.confirm_prompt.s_alert.play()
	Globals.confirm_prompt.open(body,title,[{text="OK"}])
	yield(Globals.confirm_prompt,"option_selected")
	Globals.confirm_prompt.s_back.play()
	Globals.confirm_prompt.close()
	yield(Globals.confirm_prompt,"done_closing")
	emit_signal("error_done")

const MODULO_8_BIT = 256

static func getRandomInt():
  # Randomize every time to minimize the risk of collisions
  randomize()

  return randi() % MODULO_8_BIT

static func uuidbin():
  # 16 random bytes with the bytes on index 6 and 8 modified
  return [
	getRandomInt(), getRandomInt(), getRandomInt(), getRandomInt(),
	getRandomInt(), getRandomInt(), ((getRandomInt()) & 0x0f) | 0x40, getRandomInt(),
	((getRandomInt()) & 0x3f) | 0x80, getRandomInt(), getRandomInt(), getRandomInt(),
	getRandomInt(), getRandomInt(), getRandomInt(), getRandomInt(),
  ]

static func v4():
  # 16 random bytes with the bytes on index 6 and 8 modified
  var b = uuidbin()

  return '%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x' % [
	# low
	b[0], b[1], b[2], b[3],
	# mid
	b[4], b[5],
	# hi
	b[6], b[7],
	# clock
	b[8], b[9],
	# clock
	b[10], b[11], b[12], b[13], b[14], b[15]
  ]
