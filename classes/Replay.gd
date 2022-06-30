extends Node
class_name Replay

const file_sig:PoolByteArray = PoolByteArray([0x53,0x73,0x2A,0x52])
const current_sv:int = 1

var song:Song
var cursor_positions:Array = []
var triggers:Array = []
var settings:Dictionary

var id:String
var sv:int = 0

var file:File = File.new()
var recording:bool = false
var loaded:bool = false
var autoplayer:bool = false
var end_ms:float = 0

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


signal progress
signal done_loading
func read_data(from_path:String=""):
	if !loaded:
		if from_path:
			var err:int = file.open(from_path,File.READ)
			
			if err != OK:
				replay_error("The replay could not be read. You will now be returned to the main menu.\n(file open error %s)" % err)
				return
			if file.get_buffer(4) != file_sig:
				file.close()
				replay_error("The replay is corrupted. You will now be returned to the main menu.\n(check failed)")
				return
			
			sv = file.get_16()
			
			if sv > current_sv or sv == 0:
				file.close()
				replay_error("The replay is corrupted. You will now be returned to the main menu.\n(invalid file version)")
				return
			
			file.get_64()
			id = file.get_line()
			var song_id = id.split(".")[0]
			var fsong = SSP.registry_song.get_item(song_id)
			
			if !fsong:
				file.close()
				replay_error("Could not find the song used by this replay. You will now be returned to the main menu.\n(song id: %s)" % song_id)
				return
			
			song = fsong
			SSP.selected_song = fsong
			var state = SSP.parse_pb_str(file.get_line())
			file.get_8()
			end_ms = float(file.get_32())
			
			var sigcount = file.get_32()
			if sigcount == 0:
				file.close()
				replay_error("The replay is corrupted. You will now be returned to the main menu.\n(signal count is zero)")
				return
			
			var kind:int = file.get_8()
			var i = 0
			while kind != Globals.RS_END:
				i += 1
				if fmod(i,50) == 0:
					emit_signal("progress",i/sigcount)
					yield(SSP.get_tree(),"idle_frame")
				if kind == Globals.RS_CURSOR:
					cursor_positions.append([file.get_32(),Vector2(file.get_float(),file.get_float())])
				else:
					if file.get_32() == 0:
						file.close()
						replay_error("The replay is corrupted. You will now be returned to the main menu.\n(invalid signal type %s)" % kind)
						return
				kind = file.get_8()
			emit_signal("done_loading")
			loaded = true
		else:
			autoplayer = true
			song = SSP.selected_song
			var notes = song.read_notes()
			var prev = [-1]
			for n in notes:
				var p:Array = [float(n[2]),Vector2(n[0],-n[1])]
				if SSP.mod_mirror_x: p[1].x = 2 - p[1].x
				if SSP.mod_mirror_y: p[1].y = (-p[1].y) - 2
				if p[0] != prev[0]:
					prev = p
					cursor_positions.append(p)
				else:
					prev[1] = lerp(p[1],prev[1],0.5)
			end_ms = SSP.selected_song.last_ms
			yield(SSP.get_tree(),"idle_frame")
			emit_signal("done_loading")
			loaded = true

# Playback
var last_ms:float = -100000000000
var last_pos_offset:int = 0
func get_cursor_position(ms:float):
	var start_off:int = 0
	if ms >= last_ms:
		start_off = last_pos_offset
		last_ms = ms
	
	var ap:Array
	var bp:Array
	if ms >= end_ms:
		ap = cursor_positions[cursor_positions.size()-1]
		bp = [end_ms + 3000, Vector2(1,-1)]
	else:
		for i in range(start_off,cursor_positions.size()):
			var p:Array = cursor_positions[i]
			if p[0] >= ms:
				if i != 0: ap = cursor_positions[i-1]
				else: ap = [-3000*Globals.speed_multi[SSP.mod_speed_level],Vector2(1,-1)]
				bp = p
				last_pos_offset = i
				break
	
	if !ap or !bp or ap.size() == 0 or bp.size() == 0:
		ap = cursor_positions[last_pos_offset]
		bp = [ap[0]+10,ap[1]]
	
	var v = smoothstep(ap[0],bp[0],ms)
	if autoplayer:
		var dist = bp[0] - ap[0]
		var pdist = (bp[1] - ap[1]).length()
		var curve = clamp((dist-300)/150,-clamp(((pdist-0.75)*0.5)/(dist/400),-0.5,1.2),2)
		v = ease(v,curve) # -2
	return lerp(ap[1],bp[1],v)

# Recording
var endms_offset:int = 0
var sig_count:int = 0
func store_cursor_pos(ms:float,x:float,y:float):
	if !recording: return
	sig_count += 1
	file.store_8(Globals.RS_CURSOR)
	file.store_32(floor(ms))
	last_ms = floor(last_ms)
	file.store_float(x)
	file.store_float(y)

func start_recording(with_song:Song):
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

func end_recording():
	recording = false
	sig_count += 1
	file.store_8(Globals.RS_END)
	file.seek(endms_offset)
	file.store_32(last_ms)
	file.store_32(sig_count)
	file.close()
