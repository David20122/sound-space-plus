extends Spatial
class_name NoteManager

signal ms_change
signal timer_update
signal hit
signal miss

var approach_rate:float = SSP.approach_rate
var speed_multi:float = Globals.speed_multi[SSP.mod_speed_level]
var ms:float = SSP.start_offset - (3000 * speed_multi) # make waiting time shorter on lower speeds
var notes_loaded:bool = false

var noteNodes:Array = []
var noteCache:Array = []
var noteQueue:Array = []
var colors:Array = SSP.selected_colorset.colors
var hitEffect:Spatial = load(SSP.selected_hit_effect.path).instance()
var missEffect:Spatial = load(SSP.selected_miss_effect.path).instance()
var scoreEffect:Spatial = load("res://content/notefx/score.tscn").instance()
var hit_id:String = SSP.selected_hit_effect.id
var miss_id:String = SSP.selected_miss_effect.id
var chaos_rng:RandomNumberGenerator = RandomNumberGenerator.new()

var matcache_hit:Dictionary = {}
var matcache_miss:Dictionary = {}

const base_position = Vector3(-1,1,0)

var prev_ms:float = -100000

var next_ms:float = 0

var last_cursor_position:Vector3 = Vector3(-1,1,0)

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
			var result = SSP.visual_mode or note.check($Cursor.transform.origin,last_cursor_position)
			if SSP.play_hit_snd and SSP.ensure_hitsync: 
				if SSP.sfx_2d:
					$Hit2D.play()
				else:
					$Hit.transform = note.transform
					$Hit.play()
			if !result and (ms > note.notems + SSP.hitwindow_ms or pause_state == -1):
#				note_passed = true
				# notes should not be in the hitwindow if the game is paused
				if !SSP.replaying and SSP.record_replays:
					SSP.replay.note_miss(note.id)
				note.state = Globals.NSTATE_MISS
				if SSP.play_miss_snd: 
					if SSP.sfx_2d:
						$Miss2D.play()
					else:
						$Miss.transform = note.transform
						$Miss.play()
				if SSP.show_miss_effect:
					var pos:Vector3 = Vector3(
						note.transform.origin.x,
						note.transform.origin.y,
						0.002
					)
					
					missEffect.duplicate().spawn(self,pos,note.col,miss_id,true)
				emit_signal("miss",note.col)
				prev_ms = note.notems
			elif result:
#				note_passed = true
				if !SSP.replaying and SSP.record_replays:
					SSP.replay.note_hit(note.id)
				note.state = Globals.NSTATE_HIT
				if SSP.play_hit_snd and !SSP.ensure_hitsync: 
					if SSP.sfx_2d:
						$Hit2D.play()
					else:
						$Hit.transform = note.transform
						$Hit.play()
				var pos:Vector3 = Vector3(
					$Cursor.global_transform.origin.x,
					$Cursor.global_transform.origin.y,
					0.002
				)
				if SSP.show_hit_effect and !SSP.visual_mode:
					if !SSP.hit_effect_at_cursor:
						pos.x = note.global_transform.origin.x
						pos.y = note.global_transform.origin.y
					
					hitEffect.duplicate().spawn(get_parent(),pos,note.col,hit_id,false)
				emit_signal("hit",note.col)
				var score:int = get_parent().hit(note.col)
				if SSP.score_popup:
					scoreEffect.duplicate().spawn(get_parent(),pos,note.col,score)
				
				prev_ms = note.notems
		elif ms > (note.notems + SSP.hitwindow_ms) + 100:
			if noteNodes.size() > 1:
				next_ms = noteNodes[1].notems
			elif noteQueue.size() != 0:
				next_ms = noteQueue[0][2]
			noteNodes.remove(noteNodes.find(note))
			noteCache.append(note)
			remove_child(note)
			note.visible = false
			note.state = 0
			note.spawn_effect_t = 0
			note.was_visible = false
	return note_passed

var color_index:int = 0
var note_count:int = 0

func sort_note_nodes(a,b):
	return a.notems < b.notems

func sort_note_queue(a,b):
	return a[2] < b[2]

func spawn_note(n:Array):
	if n[2] < SSP.start_offset:
		return
	if n[2] < next_ms:
		next_ms = n[2]
	var note:Note
	if noteCache.size() != 0: note = noteCache.pop_back()
	else: note = $Note.duplicate()
	
#	if !note.is_inside_tree():
	add_child(note)
	note.id = note_count
	note.transform.origin = Vector3(n[0],-n[1],8)
	if SSP.mod_mirror_x: note.transform.origin.x = 2 - note.transform.origin.x
	if SSP.mod_mirror_y: note.transform.origin.y = (-note.transform.origin.y) - 2
	note.notems = n[2]
	note.reposition(ms,approach_rate)
	note.setup(colors[color_index])
	noteNodes.append(note)
	color_index += 1
	note_count += 1
	if color_index == colors.size(): color_index = 0
	
	if noteNodes.size() != 0 and n[2] < noteNodes[0].notems:
		print("noteNodes is out of order, sorting")
		if OS.has_feature("debug"):
			Globals.notify(Globals.NOTIFY_WARN,"noteNodes is out of order, sorting","Note order enforcement")
		noteNodes.sort_custom(self,"sort_note_nodes")

func spawn_notes(notes:Array):
	notes.sort_custom(self,"sort_note_queue")
	
	next_ms = notes[0][2]
	for n in notes:
		if n[2] > SSP.start_offset and n[2] <= SSP.start_offset + 5000: # load the first 5 seconds immediately
			spawn_note(n)
		else:
			noteQueue.append(n)
	notes_loaded = true
	reposition_notes(true)


func _ready():
	$Note.speed_multi = speed_multi
	$Music.pitch_scale = speed_multi
	$Miss.stream = SSP.miss_snd
	$Hit.stream = SSP.hit_snd
	$Miss2D.stream = SSP.miss_snd
	$Hit2D.stream = SSP.hit_snd
	$Note/Mesh.mesh = load(SSP.selected_mesh.path)
	
	var m:ShaderMaterial = $Note.solid_mat
	var mt:ShaderMaterial = $Note.transparent_mat
	
	var img = Globals.imageLoader.load_if_exists("user://note")
	if img:
		m.set_shader_param("image",img)
		mt.set_shader_param("image",img)
	
	if !SSP.replaying and SSP.record_replays:
		SSP.replay = Replay.new()
		SSP.replay.start_recording(SSP.selected_song)
	
	chaos_rng.seed = hash(SSP.selected_song.id)
	
	# setup for effects (user://hit and user://miss images)
	if hitEffect.has_method("setup"): hitEffect.setup(hit_id,false)
	hitEffect.visible = false
	add_child(hitEffect)
	
	if missEffect.has_method("setup"): missEffect.setup(miss_id,true)
	missEffect.visible = false
	add_child(missEffect)
	
	# force everything to be loaded now
	yield(get_tree(),"idle_frame")
	hitEffect.duplicate().spawn(get_parent(),Vector3(0,0,-400),Color(1,1,1),hit_id,false)
	missEffect.duplicate().spawn(self,Vector3(0,0,-400),Color(1,1,1),miss_id,true)
	$Note.visible = true
	$Note.transform.origin = Vector3(0,0,-400)
	yield(get_tree(),"idle_frame")
	$Note.visible = false
	
	# Precache notes
	if SSP.visual_mode: # Precache a bunch of notes, because we're probably going to need them
		for i in range(800):
			var n = $Note.duplicate()
			noteCache.append(n)
#			add_child(n)
	else:
		for i in range(25):
			var n = $Note.duplicate()
			noteCache.append(n)

var music_started:bool = false
const cursor_offset = Vector3(1,-1,0)
onready var cam:Camera = get_node("../..").get_node("Camera")
var hlpower = (0.1 * SSP.parallax)
onready var Grid = get_node("../HUD")

func do_half_lock():
	var cursorpos = $Cursor.transform.origin
	var centeroff = cursorpos - cursor_offset
	var hlm = 0.35
	var uim = SSP.ui_parallax * 0.1
	var grm = SSP.grid_parallax * 0.1
	cam.transform.origin = Vector3(
		centeroff.x*hlpower*hlm, centeroff.y*hlpower*hlm, 3.75
	)
	Grid.transform.origin = Vector3(
		-centeroff.x*hlm*uim, -centeroff.y*hlm*uim, Grid.transform.origin.z
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
	
	var hlm = 0.35
	var uim = SSP.ui_parallax * 0.1
	var grm = SSP.grid_parallax * 0.1
	cam.transform.origin = Vector3(
		centeroff.x*hlpower*hlm, centeroff.y*hlpower*hlm, 3.5
	) + cam.transform.basis.z / 4
	Grid.transform.origin = Vector3(
		-centeroff.x*hlm*uim, -centeroff.y*hlm*uim, Grid.transform.origin.z
	)
	transform.origin = Vector3(
		-(centeroff.x*hlm*grm)-1, -(centeroff.y*hlm*grm)+1, 0
	)
	get_node("Cursor").transform.origin = centeroff + cursor_offset

func do_vr_cursor():
	var centeroff = SSP.vr_player.primary_ray.get_collision_point() + cursor_offset
	
	var cx = centeroff.x
	var cy = -centeroff.y
	cx = clamp(cx, (0 + sh.x + edgec), (3 + sh.x - edgec))
	cy = clamp(cy, (0 + sh.y + edgec), (3 + sh.y - edgec))
	centeroff.x = cx - cursor_offset.x
	centeroff.y = -cy - cursor_offset.y
	
	var hlm = 0.35
	var uim = SSP.ui_parallax * 0.1
	var grm = SSP.grid_parallax * 0.1
	cam.transform.origin = Vector3(
		centeroff.x*hlpower, centeroff.y*hlpower, 3.735
	)
	Grid.transform.origin = Vector3(
		-centeroff.x*hlm*uim, -centeroff.y*hlm*uim, Grid.transform.origin.z
	)
	transform.origin = Vector3(
		-(centeroff.x*hlm*grm)-1, -(centeroff.y*hlm*grm)+1, 0
	)
	get_node("Cursor").transform.origin = centeroff + cursor_offset

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
		if n[2] <= (ms + (spawn_ms_dist * speed_multi)):
			rem += 1
			
			spawn_note(n)
			noteQueue.remove(noteQueue.find(n))
		else:
			break


var rec_t:float = 0
var rms:float = 0
var rec_interval:float = 35
var pause_state:float = 0
var pause_ms:float = 0
var replay_unpause:bool = false
var can_skip:bool = ((next_ms-prev_ms) > 5000) and (next_ms >= max(ms+(3000*speed_multi),1100*speed_multi))
var ms_offset:float = 0

var replay_sig:Array = []
var last_usec = OS.get_ticks_usec()

func _process(delta:float):
	var u = OS.get_ticks_usec()
	delta = float(u - last_usec) / 1_000_000.0
	last_usec = u
#	delta *= Engine.time_scale
	if SSP.vr: do_vr_cursor()
	elif SSP.cam_unlock: do_spin()
	else: do_half_lock()
	if !notes_loaded: return
	
	can_skip = ((next_ms-prev_ms) > 5000) and (next_ms >= max(ms+(3000*speed_multi),1100*speed_multi))
	
	if !SSP.replaying:
		if Input.is_action_just_released("pause"):
			if pause_state > 0:
				pause_state = -1
				ms = pause_ms# - (750 * speed_multi)
				if SSP.record_replays:
					SSP.replay.store_sig(rms,Globals.RS_CANCEL_UNPAUSE)
				emit_signal("ms_change",ms)
				$Music.stop()
		elif Input.is_action_just_pressed("pause"):
			if pause_state == 0 and can_skip:
				var prev_ms = ms
				if SSP.record_replays:
					SSP.replay.store_sig(rms,Globals.RS_SKIP)
				ms = next_ms - (1000*speed_multi)
				emit_signal("ms_change",ms)
				do_note_queue()
				if (ms + SSP.music_offset) >= SSP.start_offset:
					$Music.play((ms + SSP.music_offset)/1000)
					music_started = true
			else:
				if pause_state == 0 and (ms > (1000 * speed_multi) and ms < get_parent().last_ms):
					print("PAUSED AT MS %.0f" % ms)
					if SSP.record_replays:
						SSP.replay.store_pause(rms)
					SSP.song_end_pause_count += 1
					pause_state = -1
		#			ms -= 750
					emit_signal("ms_change",ms)
					pause_ms = ms# + (750 * speed_multi)
					$Music.stop()
					get_parent().combo_level = 1
					get_parent().lvl_progress = 0
					get_parent().update_hud()
				elif pause_state != 0:
					if SSP.record_replays:
						SSP.replay.store_sig(rms,Globals.RS_START_UNPAUSE)
					pause_state = 1
					ms = pause_ms - (pause_state * (750 * speed_multi))
					emit_signal("ms_change",ms)
					$Music.volume_db = -30
					$Music.play(ms/1000)
		if Input.is_action_pressed("pause") and pause_state > 0:
			var prev_state = pause_state
			pause_state = max(pause_state - (delta/0.75), 0)
			$Music.volume_db = min($Music.volume_db + (delta * 30), 0)
			if pause_state == 0:
	#				print("YEAH baby that's what i've been waiting for")
				if (prev_state != pause_state) and SSP.record_replays:
					SSP.replay.store_sig(rms,Globals.RS_FINISH_UNPAUSE)
				$Music.volume_db = 0
				pause_state = 0
	elif SSP.replay.sv != 1:
		var should_pause:bool = false
		var should_giveup:bool = false
		var should_skip:bool = false
		var just_started_unpause:bool = false
		var just_cancelled_unpause:bool = false
		var should_end_unpause:bool = false
		if replay_sig.size() != 0:
			print(replay_sig)
		for s in replay_sig:
			if s[1] == Globals.RS_PAUSE: should_pause = true
			elif s[1] == Globals.RS_GIVEUP: should_giveup = true
			elif s[1] == Globals.RS_SKIP: should_skip = true
			elif s[1] == Globals.RS_START_UNPAUSE:
				just_started_unpause = true
				replay_unpause = true
			elif s[1] == Globals.RS_CANCEL_UNPAUSE:
				just_cancelled_unpause = true
				replay_unpause = false
			elif s[1] == Globals.RS_FINISH_UNPAUSE:
				should_end_unpause = true
		
		if should_skip:
			var prev_ms = ms
			ms = next_ms - (1000*speed_multi)
#			rms += (prev_ms - ms)
			emit_signal("ms_change",ms)
			do_note_queue()
			if (ms + SSP.music_offset) >= SSP.start_offset:
				$Music.play((ms + SSP.music_offset)/1000)
				music_started = true
		if just_cancelled_unpause:
			pause_state = -1
			ms = pause_ms# - (750 * speed_multi)
			SSP.replay.store_sig(rms,Globals.RS_CANCEL_UNPAUSE)
			emit_signal("ms_change",ms)
			$Music.stop()
		elif should_pause:
			print("PAUSED AT MS %.0f" % ms)
			if SSP.record_replays:
				SSP.replay.store_sig(rms,Globals.RS_PAUSE)
			SSP.song_end_pause_count += 1
			pause_state = -1
#			ms -= 750
			emit_signal("ms_change",ms)
			pause_ms = ms# + (750 * speed_multi)
			$Music.stop()
			get_parent().combo_level = 1
			get_parent().lvl_progress = 0
			get_parent().update_hud()
		elif just_started_unpause:
#				print("YEAH baby that's what i've been waiting for")
#				print(pause_ms)
			pause_state = 1
			ms = pause_ms - (pause_state * (750 * speed_multi))
			emit_signal("ms_change",ms)
			$Music.volume_db = -30
			$Music.play((ms + SSP.music_offset)/1000)
		if replay_unpause and pause_state >= 0:
			pause_state = max(pause_state - (delta/0.75), 0)
			$Music.volume_db = min($Music.volume_db + (delta * 30), 0)
			if should_end_unpause:
	#				print("YEAH baby that's what i've been waiting for")
				$Music.volume_db = SSP.music_volume_db
				pause_state = 0
		if should_giveup: get_parent().end(Globals.END_GIVEUP)
	
	rms += delta * 1000
	rec_t += delta * 1000
	if pause_state == 0 or (pause_state > 0 and (Input.is_action_pressed("pause") or replay_unpause)):
		ms += delta * 1000 * speed_multi
		emit_signal("ms_change",ms)
		do_note_queue()
		if (ms + SSP.music_offset) >= SSP.start_offset and !music_started:
			$Music.play((ms + SSP.music_offset)/1000)
			music_started = true
	
	if SSP.replaying:
		replay_sig = SSP.replay.get_signals(rms)
	
	emit_signal("timer_update",ms,can_skip)
	
	if $Music.playing and !SSP.disable_desync:
		var playback_pos:float = $Music.get_playback_position()*1000.0
		if abs(playback_pos - (ms + SSP.music_offset)) > (100 * max(speed_multi, 1.0)):
			if SSP.desync_alerts:
				Globals.notify(
					Globals.NOTIFY_WARN,
					"Audio was desynced by %.2f ms, correcting." % [playback_pos - (ms + SSP.music_offset)],
					"Music Sync Correction"
				)
			$Music.play((ms + SSP.music_offset)/1000.0)
	
	var rn_res:bool = reposition_notes()
	if !SSP.replaying and SSP.record_replays:
		var should_write_pos:bool = rn_res
		var ri = rec_interval
		if pause_state == -1: ri *= 3
		if rec_t >= ri:
			rec_t = 0
			should_write_pos = true
		SSP.replay.store_cursor_pos(rms,$Cursor.transform.origin.x,$Cursor.transform.origin.y)
	
	if SSP.rainbow_grid:
		$Inner.get("material/0").albedo_color = Color.from_hsv(SSP.rainbow_t*0.1,0.65,1)
		$Outer.get("material/0").albedo_color = Color.from_hsv(SSP.rainbow_t*0.1,0.65,1)


func _exit_tree():
	# Remove anything sitting outside of the tree
	scoreEffect.queue_free()
	for n in noteCache:
		n.queue_free()
