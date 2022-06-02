extends Spatial

signal ms_change
signal hit
signal miss

var approach_rate:float = SSP.approach_rate
var speed_multi:float = 1
var ms:float = -3000
var notes_loaded:bool = false

var noteNodes:Array = []
#var colors:Array = [ Color("#fc94f2"),Color("#96fc94") ]
var colors:Array = SSP.selected_colorset.colors

const base_position = Vector3(-1,1,0)

var out_of_notes:bool = false
func reposition_notes(force:bool=false):
	var for_del:int = 0
	if noteNodes.size() == 0: out_of_notes = true
	for note in noteNodes:
		if force: note.reposition(ms,SSP.approach_rate)
		else: if note.reposition(ms,SSP.approach_rate) == false: return
		if ms >= note.notems and note.state == Globals.NSTATE_ACTIVE:
			var result = note.check($Cursor.transform.origin)
			if !result and ms > note.notems + SSP.hitwindow_ms:
				note.state = Globals.NSTATE_MISS
				if SSP.play_miss_snd: $Miss.play()
				emit_signal("miss",note.col)
			elif result:
				note.state = Globals.NSTATE_HIT
				if SSP.play_hit_snd: $Hit.play()
				emit_signal("hit",note.col)
		elif ms - note.notems > 100:
			noteNodes.remove(noteNodes.find(note))
			note.queue_free()

func spawn_notes(notes:Array):
	var ci:int = 0
	for n in notes:
		var note:Note = $Note.duplicate()
		add_child(note)
		note.transform.origin = Vector3(n[0],-n[1],8)
		if SSP.mod_mirror_x: note.transform.origin.x = 2 - note.transform.origin.x
		if SSP.mod_mirror_y: note.transform.origin.y = (-note.transform.origin.y) - 2
		note.notems = n[2]
		note.reposition(ms,approach_rate)
		note.setup(colors[ci])
		noteNodes.append(note)
		ci += 1
		if ci == colors.size(): ci = 0
	notes_loaded = true
	reposition_notes(true)


func _ready():
	speed_multi = Globals.speed_multi[SSP.mod_speed_level]
	ms *= speed_multi
	$Music.pitch_scale = speed_multi
	$Miss.stream = SSP.miss_snd
	$Hit.stream = SSP.hit_snd
	$Note/Mesh.mesh = load(SSP.selected_mesh.path)
	var m:ShaderMaterial = $Note/Mesh.get("material/0")
	
	if SSP.mod_ghost:
		print("ghost!")
		m.set_shader_param("fade_out_start",((12.0/50)*SSP.approach_rate)+4.0)
		m.set_shader_param("fade_out_end",((4.0/50.0)*SSP.approach_rate)+4.0)
	
	if SSP.mod_nearsighted:
		print("nearsight!")
		m.set_shader_param("fade_in_start",((30.0/50.0)*SSP.approach_rate)+4.0)
		m.set_shader_param("fade_in_end",((5.0/50.0)*SSP.approach_rate)+4.0)
	else:
		m.set_shader_param("fade_in_start",SSP.spawn_distance+4.0)
		m.set_shader_param("fade_in_end",(SSP.spawn_distance*0.5)+4.0)
#		m.distance_fade_max_distance = (SSP.spawn_distance - min(SSP.approach_rate * 0.1, SSP.spawn_distance * 0.6))+4.0

var music_started:bool = false

const cursor_offset = Vector3(1,-1,0)

onready var cam:Camera = get_parent().get_parent().get_node("Camera")
var hlpower = (0.1 * SSP.parallax)


func do_half_lock():
	var cursorpos = $Cursor.transform.origin
	var centeroff = cursorpos - cursor_offset
	var hlm = 0.35
	var uim = SSP.ui_parallax * 0.1
	var grm = SSP.grid_parallax * 0.1
	cam.transform.origin = Vector3(
		centeroff.x*hlpower*hlm, centeroff.y*hlpower*hlm, 3.735
	)
	get_parent().get_node("Grid").transform.origin = Vector3(
		-centeroff.x*hlm*uim, -centeroff.y*hlm*uim, 0
	)
	transform.origin = Vector3(
		-(centeroff.x*hlm*grm)-1, -(centeroff.y*hlm*grm)+1, 0
	)
#	get_parent().transform.origin = Vector3(-centeroff.x*hlpower,-centeroff.y*hlpower,0) * 0.5
#	get_parent().get_node("Grid/Inner").transform.origin = Vector3(-centeroff.x*hlpower,-centeroff.y*hlpower,0) * 0.5
#	transform.origin = -cursor_offset + Vector3(-centeroff.x*hlpower,-centeroff.y*hlpower,0) * 0.5
#	if SSP.background_parallax != 0:
#		var spaceoff = (transform.origin - Vector3(-1,1,0)) * SSP.background_parallax
#		get_parent().get_parent().get_node("Space").transform.origin = spaceoff

var sh:Vector2 = Vector2(-0.5,-0.5)
var edgec:float = 0
func do_spin():
	var centeroff = get_parent().get_parent().get_node("SpinPos").global_transform.origin + cursor_offset
	
	var cx = centeroff.x
	var cy = -centeroff.y
	cx = clamp(cx, (0 + sh.x + edgec), (3 + sh.x - edgec))
	cy = clamp(cy, (0 + sh.y + edgec), (3 + sh.y - edgec))
	centeroff.x = cx - cursor_offset.x
	centeroff.y = -cy - cursor_offset.y
	
	cam.transform.origin = Vector3(
		centeroff.x*hlpower, centeroff.y*hlpower, 3.735
	)
#	get_parent().get_node("Grid/Inner").transform.origin = Vector3(-centeroff.x*hlpower,-centeroff.y*hlpower,0) * 0.5
	get_node("Cursor").transform.origin = centeroff + cursor_offset
#	transform.origin = -cursor_offset + Vector3(-centeroff.x*hlpower,-centeroff.y*hlpower,0) * 0.5
#	if get_parent().get_parent().has_node("Space"):
#		get_parent().get_parent().get_node("Space").transform.origin = -cursor_offset + Vector3(-centeroff.x*hlpower,-centeroff.y*hlpower,0) * 0.5

var pause_state:float = 0
var pause_ms:float = 0

func comma_sep(number):
	var string = str(number)
	var mod = string.length() % 3
	var res = ""
	
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]
	
	return res
	
func _process(delta:float):
#	delta *= Engine.time_scale
	if SSP.cam_unlock: do_spin()
	else: do_half_lock()
	if !notes_loaded: return
	
	
	if Input.is_action_just_released("pause"):
		if pause_state > 0:
			pause_state = -1
			get_parent().get_node("Grid/PauseHud").modulate = Color(1,1,1,1)
			get_parent().get_node("Grid/PauseVP/Control").percent = 0
			ms = pause_ms - 750
			emit_signal("ms_change",ms)
			$Music.stop()
	elif Input.is_action_just_pressed("pause"):
		if pause_state == 0 and (ms > 1100 and ms < get_parent().last_ms):
			print("PAUSED AT MS %.0f" % ms)
			SSP.song_end_pause_count += 1
			pause_state = -1
			ms -= 750
			emit_signal("ms_change",ms)
			pause_ms = ms + 750
			$Music.stop()
			get_parent().get_node("Grid/LeftVP/Control/Pauses").text = comma_sep(SSP.song_end_pause_count)
			get_parent().get_node("Grid/PauseHud").visible = true
			get_parent().get_node("Grid/PauseHud").modulate = Color(1,1,1,1)
			get_parent().get_node("Grid/PauseVP/Control").percent = 0
		else:
#				print("YEAH baby that's what i've been waiting for")
#				print(pause_ms)
			pause_state = 1
			get_parent().get_node("Grid/PauseHud").modulate = Color(1,1,1,pause_state)
			ms = pause_ms - (pause_state * 750)
			emit_signal("ms_change",ms)
			$Music.volume_db = SSP.music_volume_db - 30
			$Music.play(ms/1000)
	if Input.is_action_pressed("pause") and pause_state >= 0:
		pause_state = max(pause_state - (delta/0.75), 0)
		$Music.volume_db = min($Music.volume_db + (delta * 30), SSP.music_volume_db)
		get_parent().get_node("Grid/PauseVP/Control").percent = (1 - (pause_state / 0.75))
		get_parent().get_node("Grid/PauseHud").modulate = Color(1,1,1,pause_state)
		if pause_state == 0:
#				print("YEAH baby that's what i've been waiting for")
			get_parent().get_node("Grid/PauseHud").visible = false
			$Music.volume_db = 0
			pause_state = 0
	
	if pause_state == 0 or (pause_state > 0 and Input.is_action_pressed("pause")):
		ms += delta * 1000 * speed_multi
		emit_signal("ms_change",ms)
		if ms >= 0 and !music_started:
			$Music.play(ms/1000)
			music_started = true
	
	reposition_notes()
