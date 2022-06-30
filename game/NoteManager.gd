extends Spatial

signal ms_change
signal timer_update
signal hit
signal miss

var approach_rate:float = SSP.approach_rate
var speed_multi:float = Globals.speed_multi[SSP.mod_speed_level]
var ms:float = -(3000 * speed_multi) # make waiting time shorter on lower speeds
var notes_loaded:bool = false

var noteNodes:Array = []
var noteQueue:Array = []
var colors:Array = SSP.selected_colorset.colors
var hitEffect:Spatial = load(SSP.selected_hit_effect.path).instance()

const base_position = Vector3(-1,1,0)

var prev_ms:float = -100000
var next_ms:float = 100000

var out_of_notes:bool = false
func reposition_notes(force:bool=false):
	if noteNodes.size() == 0: out_of_notes = true
	var note_passed:bool = false
	var is_first:bool = true
	for note in noteNodes:
		if force: note.reposition(ms,SSP.approach_rate)
		else: if note.reposition(ms,SSP.approach_rate) == false: return note_passed
		if ms < note.notems and is_first:
			is_first = false
			next_ms = note.notems
		elif ms >= note.notems and note.state == Globals.NSTATE_ACTIVE:
			note_passed = true
			var result = note.check($Cursor.transform.origin)
			if !result and (ms > note.notems + SSP.hitwindow_ms or pause_state == -1):
				# notes should not be in the hitwindow if the game is paused
				note.state = Globals.NSTATE_MISS
				if SSP.play_miss_snd: $Miss.play()
#				$MissEffect.duplicate().spawn(
#					get_parent(),Vector3(
#						$Cursor.global_transform.origin.x,
#						$Cursor.global_transform.origin.y,
#						0.002
#					),note.col
#				)
				emit_signal("miss",note.col)
				prev_ms = note.notems
			elif result:
				note.state = Globals.NSTATE_HIT
				if SSP.play_hit_snd: $Hit.play()
					#$Hit.play((ms - note.notems)/1000.0)
				if SSP.show_hit_effect:
					var pos:Vector3 = Vector3(
						$Cursor.global_transform.origin.x,
						$Cursor.global_transform.origin.y,
						0.002
					)
					if !SSP.hit_effect_at_cursor:
						pos.x = note.global_transform.origin.x
						pos.y = note.global_transform.origin.y
					
					hitEffect.duplicate().spawn(get_parent(),pos,note.col)
				emit_signal("hit",note.col)
				prev_ms = note.notems
		elif ms - note.notems > 100:
			noteNodes.remove(noteNodes.find(note))
			note.queue_free()
	return note_passed

var color_index:int = 0

func spawn_note(n:Array):
	var note:Note = $Note.duplicate()
	add_child(note)
	note.transform.origin = Vector3(n[0],-n[1],8)
	if SSP.mod_mirror_x: note.transform.origin.x = 2 - note.transform.origin.x
	if SSP.mod_mirror_y: note.transform.origin.y = (-note.transform.origin.y) - 2
	note.notems = n[2]
	note.reposition(ms,approach_rate)
	note.setup(colors[color_index])
	noteNodes.append(note)
	color_index += 1
	if color_index == colors.size(): color_index = 0

func spawn_notes(notes:Array):
	for n in notes:
		if n[2] <= 5000: # load the first 5 seconds immediately
			var note:Note = $Note.duplicate()
			add_child(note)
			note.transform.origin = Vector3(n[0],-n[1],8)
			if SSP.mod_mirror_x: note.transform.origin.x = 2 - note.transform.origin.x
			if SSP.mod_mirror_y: note.transform.origin.y = (-note.transform.origin.y) - 2
			note.notems = n[2]
			note.reposition(ms,approach_rate)
			note.setup(colors[color_index])
			noteNodes.append(note)
			color_index += 1
			if color_index == colors.size(): color_index = 0
		else:
			noteQueue.append(n)
	notes_loaded = true
	reposition_notes(true)


func _ready():
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
		m.set_shader_param("fade_in_end",(SSP.spawn_distance*clamp(1 - SSP.fade_length,0,0.995))+4.0)
	
	if !SSP.replaying and SSP.record_replays:
		SSP.replay = Replay.new()
		SSP.replay.start_recording(SSP.selected_song)

var music_started:bool = false
const cursor_offset = Vector3(1,-1,0)
onready var cam:Camera = get_node("../..").get_node("Camera")
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

var sh:Vector2 = Vector2(-0.5,-0.5)
var edgec:float = 0
func do_spin():
	var centeroff = get_node("../..").get_node("SpinPos").global_transform.origin + cursor_offset
	
	var cx = centeroff.x
	var cy = -centeroff.y
	cx = clamp(cx, (0 + sh.x + edgec), (3 + sh.x - edgec))
	cy = clamp(cy, (0 + sh.y + edgec), (3 + sh.y - edgec))
	centeroff.x = cx - cursor_offset.x
	centeroff.y = -cy - cursor_offset.y
	
	cam.transform.origin = Vector3(
		centeroff.x*hlpower, centeroff.y*hlpower, 3.735
	)
	get_node("Cursor").transform.origin = centeroff + cursor_offset

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

var spawn_ms_dist:float = ((max(SSP.spawn_distance / SSP.approach_rate,0.6) * 1000) + 500)

func do_note_queue():
	var rem:int = 0
	for n in noteQueue:
		if n == noteQueue[0] and n[2] < next_ms:
			next_ms = n[2]
		if n[2] <= (ms + (spawn_ms_dist * speed_multi)):
			rem += 1
			spawn_note(n)
		else: break
	
	for _i in range(rem): noteQueue.pop_front()

onready var TimerHud = get_node("../Grid/TimerHud")
onready var ComboHud = get_node("../Grid/ComboHud")
onready var Energy = get_node("../Grid/EnergyVP/Control/Energy")


var rt:float = 0
var rec_interval:float = 20 * speed_multi
func _process(delta:float):
#	delta *= Engine.time_scale
	if SSP.cam_unlock: do_spin()
	else: do_half_lock()
	if !notes_loaded: return
	
	var can_skip:bool = (next_ms >= max(ms+(3000*speed_multi),1100*speed_multi))
	
	if !SSP.rainbow_hud:
		if can_skip: TimerHud.modulate = Color(0.7,1,1)
		else: TimerHud.modulate = Color(1,1,1)
	
	if Input.is_action_just_released("pause"):
		if pause_state > 0:
			pause_state = -1
			get_parent().get_node("Grid/PauseHud").modulate = Color(1,1,1,1)
			get_parent().get_node("Grid/PauseVP/Control").percent = 0
			ms = pause_ms# - (750 * speed_multi)
			emit_signal("ms_change",ms)
			$Music.stop()
	elif Input.is_action_just_pressed("pause"):
		if pause_state == 0 and can_skip:
			ms = next_ms - (1000*speed_multi)
			emit_signal("ms_change",ms)
			do_note_queue()
			if ms >= 0:
				$Music.play(ms/1000)
				music_started = true
		else:
			if pause_state == 0 and (ms > (1000 * speed_multi) and ms < get_parent().last_ms):
				print("PAUSED AT MS %.0f" % ms)
				SSP.song_end_pause_count += 1
				pause_state = -1
	#			ms -= 750
				emit_signal("ms_change",ms)
				pause_ms = ms# + (750 * speed_multi)
				$Music.stop()
				get_parent().get_node("Grid/LeftVP/Control/Pauses").text = comma_sep(SSP.song_end_pause_count)
				get_parent().get_node("Grid/PauseHud").modulate = Color(1,1,1,1)
				get_parent().get_node("Grid/PauseVP/Control").percent = 0
			else:
	#				print("YEAH baby that's what i've been waiting for")
	#				print(pause_ms)
				pause_state = 1
				get_parent().get_node("Grid/PauseHud").modulate = Color(1,1,1,pause_state)
				ms = pause_ms - (pause_state * (750 * speed_multi))
				emit_signal("ms_change",ms)
				$Music.volume_db = SSP.music_volume_db - 30
				$Music.play(ms/1000)
	if Input.is_action_pressed("pause") and pause_state >= 0:
		pause_state = max(pause_state - (delta/0.75), 0)
		$Music.volume_db = min($Music.volume_db + (delta * 30), SSP.music_volume_db)
		if pause_state == 0:
#				print("YEAH baby that's what i've been waiting for")
			get_parent().get_node("Grid/PauseHud").visible = false
			$Music.volume_db = 0
			pause_state = 0
	
	# Ensure pause screen is always visible when paused
	if pause_state != 0:
		get_parent().get_node("Grid/PauseHud").visible = !Input.is_key_pressed(KEY_C)
		get_parent().get_node("Grid/PauseVP/Control").percent = clamp(1 - (pause_state / 0.75),0,1)
		get_parent().get_node("Grid/PauseHud").modulate = Color(1,1,1,abs(pause_state))
	else:
		get_parent().get_node("Grid/PauseHud").visible = false
	
	if pause_state == 0 or (pause_state > 0 and Input.is_action_pressed("pause")):
		ms += delta * 1000 * speed_multi
		rt += delta * 1000 * speed_multi
		emit_signal("ms_change",ms)
		do_note_queue()
		if ms >= 0 and !music_started:
			$Music.play(ms/1000)
			music_started = true
	
	emit_signal("timer_update",ms,can_skip)
	
	var rn_res:bool = reposition_notes()
	if !SSP.replaying and SSP.record_replays:
		var should_write_pos:bool = rn_res
		if rt >= rec_interval:
			rt -= rec_interval
			should_write_pos = true
		if ms >= 0: SSP.replay.store_cursor_pos(ms,$Cursor.transform.origin.x,$Cursor.transform.origin.y)
	
	if SSP.rainbow_grid:
		$Inner.get("material/0").albedo_color = Color.from_hsv(SSP.rainbow_t*0.1,0.65,1)
		$Outer.get("material/0").albedo_color = Color.from_hsv(SSP.rainbow_t*0.1,0.65,1)
	if SSP.rainbow_hud:
		Energy.get("custom_styles/fg").bg_color = Color.from_hsv(SSP.rainbow_t*0.1,0.4,1)
		Energy.get("custom_styles/bg").bg_color = Color.from_hsv(SSP.rainbow_t*0.1,0.4,0.2,0.65)
		TimerHud.modulate = Color.from_hsv(SSP.rainbow_t*0.1,0.4,1)
		ComboHud.modulate = Color.from_hsv(SSP.rainbow_t*0.1,0.4,1)
		get_node("../Grid/LeftHud").modulate = Color.from_hsv(SSP.rainbow_t*0.1,0.4,1)
		get_node("../Grid/RightHud").modulate = Color.from_hsv(SSP.rainbow_t*0.1,0.4,1)
	
	
