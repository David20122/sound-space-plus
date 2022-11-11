extends Resource
class_name Replay

const file_sig:PoolByteArray = PoolByteArray([0x53,0x73,0x2A,0x52])
const current_sv:int = 2
const debug:bool = false

var dance:DanceMover
var song:Song
var past_cursor_positions:Array = []
var cursor_positions:Array = []
var past_triggers:Array = []
var triggers:Array = []
var note_results:Dictionary = {}
var settings:Dictionary

var id:String
var sv:int = 2 # make autoplayer behave

var file:File = File.new()
var recording:bool = false
var loaded:bool = false
var autoplayer:bool = false
var end_ms:float = 0

var read_start_offset:int = 0

func replay_error(txt:String):
	SSP.get_tree().paused = true
	Globals.confirm_prompt.s_alert.play()
	Globals.confirm_prompt.open(txt,"Error",[{text="OK"}])
	yield(Globals.confirm_prompt,"option_selected")
	Globals.confirm_prompt.s_back.play()
	Globals.confirm_prompt.close()
	yield(Globals.confirm_prompt,"done_closing")
	SSP.just_ended_song = false # Prevent PB handling
	SSP.get_tree().change_scene("res://menuload.tscn")

var debug_label:Label

var debug_txt = {}

signal progress
signal done_loading

func update_debug_text():
	if debug:
		var txt:String = "-- replay debug --"
		for k in debug_txt.keys():
			txt += "\n%s: %s" % [k,String(debug_txt[k])]
		debug_label.text = txt
		debug_label.raise()

func read_data(from_path:String=""):
	print("reading data")
	if !loaded:
		if debug:
			if Globals.get_tree().root.has_node("ReplayDebug"):
				debug_label = Globals.get_tree().root.get_node("ReplayDebug")
			else:
				debug_label = Label.new()
				Globals.get_tree().root.add_child(debug_label)
				debug_label.set("custom_fonts/font",load("res://font/debug.tres"))
				debug_label.name = "ReplayDebug"
				debug_label.rect_position = Vector2(10,10)
				debug_label.text = "-- replay debug --"
			debug_label.raise()
			
			debug_txt = { source_path = from_path }
			update_debug_text()
		
		if from_path:
			var err:int = file.open(from_path,File.READ)
			
			debug_txt.autoplayer = false
			update_debug_text()
			
			if err != OK:
				replay_error("The replay could not be read. You will now be returned to the main menu.\n(file open error %s)" % err)
				return
			if file.get_buffer(4) != file_sig:
				file.close()
				replay_error("The replay is corrupted. You will now be returned to the main menu.\n(check failed)")
				return
			
			sv = file.get_16()
			debug_txt.sv = sv
			update_debug_text()
			
			if sv > current_sv or sv == 0:
				file.close()
				replay_error("The replay is corrupted. You will now be returned to the main menu.\n(invalid file version)")
				return
			
			debug_txt.reserved_1 = file.get_64()
			id = file.get_line()
			var song_id = id.split(".")[0]
			var fsong = SSP.registry_song.get_item(song_id)
			
			debug_txt.replay_id = id
			debug_txt.song_id = song_id
			update_debug_text()
			
			if !fsong:
				file.close()
				replay_error("Could not find the song used by this replay. You will now be returned to the main menu.\n(song id: %s)" % song_id)
				return
			
			song = fsong
			SSP.selected_song = fsong
			var state_str = file.get_line()
			var state = SSP.parse_pb_str(state_str)
			debug_txt.state_str_after_offset = file.get_position()
			SSP.apply_state(state)
			debug_txt.state_str = state_str
			debug_txt.state = state
			
			debug_txt.reserved_2 = file.get_8()
			end_ms = float(file.get_32())
			debug_txt.end_ms = end_ms
			update_debug_text()
			
			var sigcount = file.get_32()
			debug_txt.sigcount = sigcount
			update_debug_text()
			
			if sigcount == 0:
				file.close()
				replay_error("The replay is corrupted. You will now be returned to the main menu.\n(signal count is zero)")
				return
			
			read_start_offset = file.get_position()
			debug_txt.read_start_offset = read_start_offset
			update_debug_text()
			
			var kind:int = file.get_8()
			print(kind)
			var i = 0
			var cursor_unrev = []
			while kind != Globals.RS_END:
				i += 1
				debug_txt.kind = kind
				debug_txt.i = i
				update_debug_text()
				if fmod(i,70) == 0:
					emit_signal("progress",(float(i)/float(sigcount)) * 0.6)
					yield(SSP.get_tree(),"idle_frame")
				
				if kind == Globals.RS_CURSOR:
					var ms = file.get_32()
					var c = Vector3(file.get_float(),file.get_float(),ms)
					debug_txt.c = c
					cursor_unrev.append(c)
					
				elif kind == Globals.RS_PAUSE and sv >= 2:
					var ms = file.get_32()
					triggers.append([ms,Globals.RS_PAUSE])
					
				elif kind == Globals.RS_START_UNPAUSE and sv >= 2:
					var ms = file.get_32()
					triggers.append([ms,Globals.RS_START_UNPAUSE])
					
				elif kind == Globals.RS_CANCEL_UNPAUSE and sv >= 2:
					var ms = file.get_32()
					triggers.append([ms,Globals.RS_CANCEL_UNPAUSE])
				
				elif kind == Globals.RS_SKIP and sv >= 2:
					var ms = file.get_32()
					triggers.append([ms,Globals.RS_SKIP])
					
				elif kind == Globals.RS_FINISH_UNPAUSE and sv >= 2:
					var ms = file.get_32()
					triggers.append([ms,Globals.RS_FINISH_UNPAUSE])
					
				elif kind == Globals.RS_GIVEUP and sv >= 2:
					var ms = file.get_32()
					triggers.append([ms,Globals.RS_GIVEUP])
					
				elif kind == Globals.RS_HIT and sv >= 2:
					var nid = file.get_32()
					note_results[nid] = true
					
				elif kind == Globals.RS_MISS and sv >= 2:
					var nid = file.get_32()
					note_results[nid] = false
					
				else:
					file.close()
					replay_error("The replay is corrupted. You will now be returned to the main menu.\n(invalid signal type %s)" % kind)
					return
				kind = file.get_8()
			if sv != 1 and note_results.size() == 0:
				file.close()
				replay_error("The replay is corrupted. You will now be returned to the main menu.\n(no note data)")
				return
			
			i = 0
			var curcount = cursor_unrev.size()
			for num in range(cursor_unrev.size()):
				debug_txt.i = num
				update_debug_text()
				if fmod(num,250) == 0:
					emit_signal("progress",0.6 + ((float(num)/float(curcount)) * 0.4))
					yield(SSP.get_tree(),"idle_frame")
				cursor_positions.append(cursor_unrev.pop_back())
			
			debug_txt.noteres_amt = note_results.size()
			debug_txt.cur_amt = cursor_positions.size()
			debug_txt.trig_amt = triggers.size()
			update_debug_text()
			
			print("nr: ",note_results.size())
			print("cur: ",cursor_positions.size())
			print("tr: ",triggers.size())
			emit_signal("done_loading")
			loaded = true
		else:
			autoplayer = true
			debug_txt.autoplayer = true
			update_debug_text()
			song = SSP.selected_song
			dance = DirectionalDanceMover.new(song)
#			var notes = song.read_notes()
#			var prev = Vector3(1,-1,-1)
#			var cursor_unrev = []
#			var i = 0
#			for n in notes:
#				i += 1
#				if fmod(i,250) == 0:
#					emit_signal("progress",(float(i)/float(notes.size())) * 0.6)
#					yield(SSP.get_tree(),"idle_frame")
#				var p:Vector3 = Vector3(n[0],-n[1],float(n[2]))
#				if SSP.mod_mirror_x: p.x = 2 - p.x
#				if SSP.mod_mirror_y: p.y = (-p.y) - 2
#				if p.z != prev.z:
#					prev = p
#					cursor_unrev.append(p)
#				else:
#					prev.x = lerp(p.x,prev.x,0.5)
#					prev.y = lerp(p.y,prev.y,0.5)
#
#			var curcount = cursor_unrev.size()
#			debug_txt.c_r_mismatch = 0
#			for num in range(cursor_unrev.size()):
#				debug_txt.i = num
#				update_debug_text()
#				if fmod(num,250) == 0:
#					emit_signal("progress",0.6 + ((float(num)/float(curcount)) * 0.4))
#					yield(SSP.get_tree(),"idle_frame")
#				var c:Vector3 = cursor_unrev.pop_back()
#				var r:Vector3 = Vector3(clamp(c.x,-0.5,2.5),clamp(c.y,-2.5,0.5),c.z)
#				if c != r:
#					print("c/r mismatch! %s != %s" % [String(c),String(r)])
#					debug_txt.c_r_mismatch += 1
#				cursor_positions.append(r)
#
			end_ms = SSP.selected_song.last_ms
			yield(SSP.get_tree(),"idle_frame")
			emit_signal("done_loading")
			loaded = true

# Playback
var last_ms:float = -100000000000
var last_pos_offset:int = 0

func get_cursor_position(ms:float):
	if autoplayer:
		return Vector2(1,-1)*dance.update(ms)
	else:
		var start_off:int = last_pos_offset
		debug_txt.ms = ms
		debug_txt.start_off = last_pos_offset
		update_debug_text()
	#	if ms >= last_ms:
	#		start_off = last_pos_offset
	#		last_ms = ms
		var ap:Vector3
		var bp:Vector3
		var rem = 0
		if ms >= end_ms:
			ap = cursor_positions[cursor_positions.size()-1]
			bp = Vector3(1,-1,end_ms+3000)
		else:
			for i in range(cursor_positions.size()-2,0,-1):
				var p:Vector3 = cursor_positions[i]
				if p.z >= ms:
	#				breakpoint
					if i != cursor_positions.size(): ap = cursor_positions[i+1]
					else: ap = Vector3(1,-1,-3000*Globals.speed_multi[SSP.mod_speed_level])
					bp = p
					last_pos_offset = i
					break
				else:
					rem += 1
		
		if !ap or !bp:
			ap = cursor_positions[last_pos_offset]
			bp = Vector3(ap.x,ap.y,ap.z+10)
		
		var i = last_pos_offset
		rem = max(rem-1,0)
		var rc = 0
		for _n in range(rem):
			cursor_positions.remove(cursor_positions.size()-1)
			rc += 1
			rem += 1
			i -= 1
		last_pos_offset -= i
		
		
		var a2 = Vector2(ap.x,ap.y)
		var b2 = Vector2(bp.x,bp.y)
		var v = clamp(smoothstep(ap.z,bp.z,ms),0,1)
		debug_txt.rc = rc
		debug_txt.rem = rem
		debug_txt.i = i
		debug_txt.cpos_size = cursor_positions.size()
		debug_txt.a = ap
		debug_txt.b = bp
		debug_txt.v = v
		
		var res:Vector2 = lerp(a2,b2,v)
		debug_txt.result = res
		update_debug_text() 
		return res

var last_sig_ms:float = -100000000000
var last_sig_offset:int = -1
func get_signals(ms:float) -> Array:
	var out:Array = []
	for p in triggers:
		if p[0] <= ms:
			out.append(p)
			triggers.pop_front()
		else: break
	
	if out.size() != 0: print("out ",out)
	return out

func should_hit(nid:int) -> bool:
	if autoplayer: return true
	if !note_results.has(nid): return false
	return note_results[nid]

# Recording
var endms_offset:int = 0
var sig_count:int = 0

var max_usec = 0
func store_cursor_pos(ms:float,x:float,y:float):
	if !recording: return
	var a = OS.get_ticks_usec()
	sig_count += 1
	file.store_8(Globals.RS_CURSOR)
	file.store_32(floor(ms))
	last_ms = max(last_ms,floor(ms))
	file.store_float(x)
	file.store_float(y)
	if debug:
		max_usec = max(max_usec,OS.get_ticks_usec() - a)

func note_miss(nid:int):
	if !recording: return
	var a = OS.get_ticks_usec()
	sig_count += 1
	file.store_8(Globals.RS_MISS)
	file.store_32(nid)
	if debug:
		print("note %s miss saved @ #%s, took %s usec" % [nid,sig_count,Globals.comma_sep(OS.get_ticks_usec() - a)])

func note_hit(nid:int):
	if !recording: return
	var a = OS.get_ticks_usec()
	sig_count += 1
	file.store_8(Globals.RS_HIT)
	file.store_32(nid)
	if debug:
		print("note %s hit saved @ #%s, took %s usec" % [nid,sig_count,Globals.comma_sep(OS.get_ticks_usec() - a)])

func store_sig(ms:float,sig:int):
	if !recording: return
	var a = OS.get_ticks_usec()
	sig_count += 1
	file.store_8(sig)
	file.store_32(floor(ms))
	if debug:
		print("signal %s saved @ #%s, ms %s, took %s usec" % [sig,sig_count,ms,Globals.comma_sep(OS.get_ticks_usec() - a)])

func store_pause(ms:float):
	if !recording: return
	var a = OS.get_ticks_usec()
	sig_count += 1
	file.store_8(Globals.RS_PAUSE)
	file.store_32(floor(ms))
	if debug:
		print("pause saved @ #%s, ms %s, took %s usec" % [sig_count,ms,Globals.comma_sep(OS.get_ticks_usec() - a)])

func store_giveup(ms:float):
	if !recording: return
	var a = OS.get_ticks_usec()
	sig_count += 1
	file.store_8(Globals.RS_GIVEUP)
	file.store_32(floor(ms))
	if debug:
		print("giveup saved @ #%s, ms %s, took %s usec" % [sig_count,ms,Globals.comma_sep(OS.get_ticks_usec() - a)]) 

func start_recording(with_song:Song):
	var a = OS.get_ticks_usec()
	var dt = OS.get_datetime()
	song = with_song
	id = "%s.%s-%s-%s_%s-%s-%s" % [song.id,dt.year,dt.month,dt.day,dt.hour,dt.minute,dt.second]
	var err:int = file.open(Globals.p("user://replays/%s.sspre" % id),File.WRITE)
	file.store_buffer(file_sig)
	file.store_16(current_sv)
	file.store_64(0)
	file.store_line(id)
	file.store_line(SSP.generate_pb_str())
	file.store_8(0)
	endms_offset = file.get_position()
	file.store_32(0)
	file.store_32(0)
	recording = true
	if debug:
		print("Recording startup took %s usec" % [Globals.comma_sep(OS.get_ticks_usec() - a)])

func end_recording():
	var a = OS.get_ticks_usec()
	recording = false
	sig_count += 1
	file.store_8(Globals.RS_END)
	file.seek(endms_offset)
	file.store_32(last_ms)
	file.store_32(sig_count)
	file.close()
	if debug:
		print("Recording end took %s usec. Highest cursor save time was %s usec." % [Globals.comma_sep(OS.get_ticks_usec() - a),max_usec])
