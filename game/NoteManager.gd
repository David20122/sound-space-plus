extends Spatial
class_name NoteManager

signal ms_change
signal timer_update
signal hit
signal miss

export(Material) var note_solid_mat
export(Material) var note_transparent_mat
export(Material) var asq_mat

var approach_rate:float = SSP.get("approach_rate")
var speed_multi:float = Globals.speed_multi[SSP.mod_speed_level]
var ms:float = SSP.start_offset - (3000 * speed_multi) # make waiting time shorter on lower speeds
var notes_loaded:bool = false
var hitsync_ensured:bool = false

var active:bool = false

var noteNodes:Array = []
var noteCache:Array = []
var noteQueue:Array = []
var colors:Array = SSP.selected_colorset.colors
var hitEffect:Spatial = load(SSP.selected_hit_effect.path).instance()
var missEffect:Spatial = load(SSP.selected_miss_effect.path).instance()
var scoreEffect:Spatial = load("res://assets/notefx/score.tscn").instance()
var hit_id:String = SSP.selected_hit_effect.id
var miss_id:String = SSP.selected_miss_effect.id
var chaos_rng:RandomNumberGenerator = RandomNumberGenerator.new()
var earthquake_rng:RandomNumberGenerator = RandomNumberGenerator.new()

var matcache_hit:Dictionary = {}
var matcache_miss:Dictionary = {}

const base_position = Vector3(-1,1,0)

var prev_ms:float = -100000

var next_ms:float = 0

var last_cursor_position:Vector3 = Vector3(-1,1,0)


# new mmi note stuff
var fade_in_enabled:bool = true
var fade_in_start:float = 8
var fade_in_end:float = 6

var fade_out_enabled:bool = false
var fade_out_start:float = 3
var fade_out_end:float = 1

var fade_out_base:float = 1


var notes:Array = []
var current_note:int = 0
var note_transform_scale:Vector3

var grid_pushback:float = 0.1 # default 0.1
var pushback_defaults:Dictionary = {
	"do_pushback": 4,
	"never": 0.1
}

func linstep(a:float,b:float,x:float):
	if a == b: return float(x >= a)
	return clamp(((x - a) / (b - a)),0,1)

func note_reposition(i:int):
	var real_position:Vector2 = notes[i][0]
	var notems:float = notes[i][1]
	var state:int = notes[i][2]
	var col:Color = notes[i][3]
	var chaos_offset:Vector2 = notes[i][4]
	var nt:Transform = notes[i][5]
	
	var approachSpeed:float = approach_rate / speed_multi
	
	var current_offset_ms:float = notems - ms
	var current_dist:float = approachSpeed*current_offset_ms/1000
	
	if (
		(current_dist <= SSP.get("spawn_distance") and current_dist >= (grid_pushback * -1) and sign(approachSpeed) == 1) or
		(current_dist >= -50 and current_dist <= 0.1 and sign(approachSpeed) == -1) or
		sign(approachSpeed) == 0
	) and state == Globals.NSTATE_ACTIVE: # state 2 = miss # and current_dist >= -0.5
		
#		if !was_visible:
#			was_visible = true
#			if SSP.note_spawn_effect:
#				if !SSP.mod_nearsighted: spawn_effect_t = 1
		
		
		nt.origin.z = -current_dist
#		visible = true
		
		
		if SSP.mod_chaos:
			var v = ease(max((current_offset_ms-250)/400,0),1.5)
			nt.origin.x = real_position.x + (chaos_offset.x * v)	
			nt.origin.y = real_position.y + (chaos_offset.y * v)
		
		if SSP.mod_earthquake:
			var rcoord = Vector2(earthquake_rng.randf_range(-0.25,0.25),earthquake_rng.randf_range(-0.25,0.25))
			nt.origin.x = real_position.x + (rcoord.x * (current_dist * 0.1))
			nt.origin.y = real_position.y + (rcoord.y * (current_dist * 0.1))
		
#		if SSP.note_visual_approach:
#			$Approach.opacity = 1 - (current_dist / SSP.get("spawn_distance"))
#
#			$Approach.scale.x = 0.4 * ((current_dist / SSP.get("spawn_distance")) + 0.6)
#			$Approach.scale.y = 0.4 * ((current_dist / SSP.get("spawn_distance")) + 0.6)
#
#			$Approach.global_translation.z = 0
			
		# note spin; not doing this all in a single Vector3 because we're trying to rotate locally
		nt.basis = nt.basis.rotated(Vector3(1,0,0),SSP.note_spin_x / 2000)
		nt.basis = nt.basis.rotated(Vector3(0,1,0),SSP.note_spin_y / 2000)
		nt.basis = nt.basis.rotated(Vector3(0,0,1),SSP.note_spin_z / 2000)
		
		var alpha:float = SSP.note_opacity
		var fade_in:float = 1
		var fade_out:float = 1
		
		if fade_in_enabled or fade_out_enabled:
			
			if fade_in_enabled: 
				fade_in = pow(linstep(fade_in_start,fade_in_end,current_dist), 1.3)
			if fade_out_enabled:
				fade_out = (1 - fade_out_base) + (pow(linstep(fade_out_end,fade_out_start,current_dist), 1.3) * fade_out_base)
			
			alpha = min(fade_in,fade_out)
		
		
		$Notes.multimesh.set_instance_transform(i - current_note, nt)
		$Notes.multimesh.set_instance_color(i - current_note, Color(col.r, col.g, col.b, col.a * alpha))
		if asq:
			var sc = (linstep(0,SSP.get("spawn_distance"),current_dist) + 0.6) * 0.4
			
			var at = Transform()
			at = at.scaled(Vector3(sc,sc,sc))
			at.origin = nt.origin#Vector3(nt.origin.x, nt.origin.y, 0)
			if !SSP.visual_approach_follow:
				at.origin.z = 0
			
			$ASq.multimesh.set_instance_transform(i - current_note, at)
			$ASq.multimesh.set_instance_color(i - current_note, Color(1,1,1,pow(linstep(SSP.get("spawn_distance"),0,current_dist),1.7)))
		
#		$Label.text += "(%.02f: %s -> %s = %s) %s\n" % [current_dist,fade_in_start,fade_in_end,fade_in,alpha]
		
		return true
	else:
		$Notes.multimesh.set_instance_transform(i - current_note, Transform(Basis(), Vector3(0, 0, 10)))
		$Notes.multimesh.set_instance_color(i - current_note, Color(0,0,0,0))
		if asq:
			$ASq.multimesh.set_instance_transform(i - current_note, Transform(Basis(), Vector3(0, 0, 10)))
			$ASq.multimesh.set_instance_color(i - current_note, Color(0,0,0,0))
#		if SSP.play_hit_snd and SSP.ensure_hitsync: 
#			if SSP.sfx_2d:
#				$"../Hit2D".play()
#			else:
#				$"../Hit".transform = transform
#				$"../Hit".play()
#		visible = false
		return false#!(state == Globals.NSTATE_ACTIVE and sign(approachSpeed) == 1 and current_dist > 100)

func note_check_collision(i:int):
	var cpos:Vector3 = $Cursor.transform.origin
	
	if SSP.replaying and SSP.replay.sv != 1:
		return SSP.replay.should_hit(i)
	else:
		var hbs:float = SSP.note_hitbox_size/2
		if hbs == 0.57: hbs = 0.56875 # 1.1375
		var ori:Vector2 = notes[i][0]
		return (cpos.x <= ori.x + hbs and cpos.x >= ori.x - hbs) and (cpos.y <= ori.y + hbs and cpos.y >= ori.y - hbs)

var asq = SSP.note_visual_approach
var last_reposition_ms:float = -10000
var out_of_notes:bool = false
func reposition_notes(force:bool=false,rerun_start:int=-1):
	var rerun_required:bool = false
	$Label.text = ""
#	force = force or OS.has_feature("debug")
	if current_note == notes.size():
#		$Label.text += "out_of_notes\n"
		$Notes.multimesh.visible_instance_count = 0
		if asq: $ASq.multimesh.visible_instance_count = 0
		out_of_notes = true
		return false
	
	var note_passed:bool = false
	var is_first:bool = true
	
#	$Label.text += "ms: %s\n\n" % [ ms ]
#	$Label.text += "current: %s\n" % [ current_note ]
#	$Label.text += "total: %s\n" % [ notes.size() ]
#	$Label.text += "visible: %s\n" % [ $Notes.multimesh.visible_instance_count ]
	
	if last_reposition_ms > ms:
#		$Label.text += "rewind detected\n"
		print("rewind detected")
		for i in range(0, notes.size()):
			if notes[i][1] > ms:
				current_note = max(i - 1, 0)
				break
	
	last_reposition_ms = ms
	
	for i in range(max(current_note,rerun_start), notes.size()):
		var notems:float = notes[i][1]
		next_ms = notems
		if force:
#			if is_first: $Label.text += "force\n"
			note_reposition(i)
		else:
			if note_reposition(i) == false:
#				$Label.text += "(%s) reposition == false\n" % [ i ]
				$Notes.multimesh.visible_instance_count = i - current_note + 1
				if asq: $ASq.multimesh.visible_instance_count = i - current_note + 1
				if ms < notems:
#					$Label.text += "(%s) note is end of visible area\n" % [ i ]
					if notes[i][2] == Globals.NSTATE_ACTIVE:
						return note_passed
		
		if (i - current_note + 2) > $Notes.multimesh.instance_count:
			rerun_required = true
			$Notes.multimesh.instance_count = min($Notes.multimesh.instance_count + 10, notes.size())
			if asq: $ASq.multimesh.instance_count = $Notes.multimesh.instance_count
			break
		
		if ms < notems and is_first:
			is_first = false
#			$Label.text += "next_ms: %s\n" % [ notems ]
#			next_ms = notems
		elif ms >= notems and notes[i][2] == Globals.NSTATE_ACTIVE:
			var result = SSP.visual_mode or note_check_collision(i)

			if !result and (ms > notems + SSP.hitwindow_ms or pause_state == -1):
#				$Label.text += "MISS %s @ %s\n" % [ i, ms ]
#				note_passed = true
				# notes should not be in the hitwindow if the game is paused
				if !SSP.replaying and SSP.record_replays:
					SSP.replay.note_miss(i)
				notes[i][2] = Globals.NSTATE_MISS
				if SSP.play_miss_snd: 
					if SSP.sfx_2d:
						$Miss2D.play()
					else:
						$Miss.transform = notes[i][5]
						$Miss.play()
				if SSP.show_miss_effect:
					var pos:Vector3 = Vector3(
						notes[i][5].origin.x,
						notes[i][5].origin.y,
						0.002
					)

					missEffect.duplicate().spawn(self,pos,notes[i][3],miss_id,true)
				emit_signal("miss",notes[i][3])
				prev_ms = notems
			elif result:
#				$Label.text += "HIT %s @ %s\n" % [ i, ms ]
#				note_passed = true
				if !SSP.replaying and SSP.record_replays:
					SSP.replay.note_hit(i)
				notes[i][2] = Globals.NSTATE_HIT
				if SSP.play_hit_snd and !SSP.ensure_hitsync: 
					if SSP.sfx_2d:
						$Hit2D.play()
					else:
						$Hit.transform = notes[i][5]
						$Hit.play()
				var pos:Vector3 = Vector3(
					$Cursor.global_transform.origin.x,
					$Cursor.global_transform.origin.y,
					0.002
				)
				if SSP.show_hit_effect and !SSP.visual_mode:
					if !SSP.hit_effect_at_cursor:
						pos.x = (global_transform * notes[i][5]).origin.x
						pos.y = (global_transform * notes[i][5]).origin.y

					hitEffect.duplicate().spawn(get_parent(),pos,notes[i][3],hit_id,false)
				emit_signal("hit",notes[i][3])
				var score:int = get_parent().hit(notes[i][3])
				if SSP.score_popup:
					scoreEffect.duplicate().spawn(get_parent(),pos,notes[i][3],score)

				prev_ms = notems
		elif ms > (notems + SSP.hitwindow_ms) + 100:
#			$Label.text += "PASS %s\n" % [ i ]

			# ensure hitsync ; not compatible with spatial hitsounds
			if SSP.play_hit_snd and SSP.ensure_hitsync:
				var dhs = $Hit2D.duplicate()
				dhs.set_script(load("res://classes/hitsync_free.gd"))
				add_child(dhs)
				var played = false
				if not played:
					played = true
					dhs.play()
		
			current_note = i + 1
#	$Label.text += "last note is visible!"
	$Notes.multimesh.visible_instance_count = notes.size() - current_note
	if asq: $ASq.multimesh.visible_instance_count = notes.size() - current_note
	
	if rerun_required: reposition_notes()
	return note_passed

var color_index:int = 0
var note_count:int = 0

func sort_note_nodes(a,b):
	return a.notems < b.notems

func sort_note_queue(a,b):
	return a[2] < b[2]

func spawn_notes(note_array:Array):
	note_array.sort_custom(self,"sort_note_queue")
	
	var nscale = 0.45 * SSP.note_size * (SSP.note_hitbox_size / 1.14)
	note_transform_scale = Vector3(nscale, nscale, nscale)
	
	next_ms = note_array[0][2]
	var colorset:Array = SSP.selected_colorset.colors
	for i in range(note_array.size()):
		var data:Array = note_array[i]
		if (data[2] >= SSP.start_offset):
			var note:Array = [
				Vector2(data[0], -data[1]), # position
				
				data[2], # notems
				
				Globals.NSTATE_ACTIVE, # state
				
				colorset[i % colorset.size()], # color
				
				Vector2( # chaos offset
					chaos_rng.randf_range(-1,1),
					chaos_rng.randf_range(-1,1)
				).normalized() * 2,
				
				Transform(), # note transform
			]
			
			if SSP.mod_mirror_x: note[0].x = 2 - note[0].x
			if SSP.mod_mirror_y: note[0].y = (-note[0].y) - 2
			note[5] = note[5].scaled(note_transform_scale)
			note[5].origin = Vector3(note[0].x,note[0].y,4)
			
			
			notes.append(note)
	
	var last_ms = note_array[-1][2]
	var inst_count = max(35,ceil(10000 * (float(notes.size()) / float(last_ms))))
	$Notes.multimesh.instance_count = inst_count
	if asq:
		$ASq.multimesh.instance_count = inst_count
		
	notes_loaded = true
	call_deferred("reposition_notes",true)


func _ready():
	if SSP.do_note_pushback:
		grid_pushback = pushback_defaults.do_pushback
	else:
		grid_pushback = pushback_defaults.never
	
	$Note.speed_multi = speed_multi
	$Music.pitch_scale = speed_multi
	if SSP.retain_song_pitch and not speed_multi == 1.0:
		var shift = AudioEffectPitchShift.new()
		shift.pitch_scale = 1.0 / speed_multi
		AudioServer.add_bus_effect(AudioServer.get_bus_index("Music"),shift)
	$Miss.stream = SSP.miss_snd
	$Hit.stream = SSP.hit_snd
	$Miss2D.stream = SSP.miss_snd
	$Hit2D.stream = SSP.hit_snd
	
	
	if !SSP.replaying and SSP.record_replays:
		SSP.replay = Replay.new()
		SSP.replay.start_recording(SSP.selected_song)
	
	chaos_rng.seed = hash(SSP.selected_song.id)
	earthquake_rng.seed = hash(SSP.selected_song.id)
	
	
	if SSP.mod_ghost:
		fade_out_enabled = true
		fade_out_start = ((18.0/50)*approach_rate)
		fade_out_end = ((6.0/50.0)*approach_rate)
		
	elif SSP.half_ghost:
		fade_out_enabled = true
		fade_out_start = ((12.0/50)*approach_rate)
		fade_out_end = ((3.0/50.0)*approach_rate)
		fade_out_base = 0.8
	
	if SSP.mod_nearsighted:
		fade_in_enabled = true
		fade_in_start = ((30.0/50.0)*approach_rate)
		fade_in_end = ((5.0/50.0)*approach_rate)
	else:
		fade_in_enabled = SSP.get("fade_length") != 0
		if SSP.get("fade_length") != 0: 
			fade_in_start = SSP.get("spawn_distance")
			fade_in_end = SSP.get("spawn_distance")*(1.0 - SSP.get("fade_length"))
	
	
	$Notes.multimesh = MultiMesh.new()
	$Notes.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	$Notes.multimesh.color_format = MultiMesh.COLOR_FLOAT
	$Notes.multimesh.instance_count = 1
	if asq:
		$ASq.multimesh = MultiMesh.new()
		$ASq.multimesh.transform_format = MultiMesh.TRANSFORM_3D
		$ASq.multimesh.color_format = MultiMesh.COLOR_8BIT
		$ASq.multimesh.mesh = QuadMesh.new()
		$ASq.multimesh.mesh.size = Vector2(3.35,3.35)
		$ASq.multimesh.mesh.surface_set_material(0,asq_mat)
		$ASq.multimesh.instance_count = 1
	else:
		$ASq.visible = false
	
	
	var mesh:Mesh
	if "user://" in SSP.selected_mesh.path:
		var m = ObjParse.load_obj(SSP.selected_mesh.path)
		if m != null:
			mesh = m
		else:
			mesh = load("res://assets/blocks/rounded.obj")
	else:
		mesh = load(SSP.selected_mesh.path)
	
	
	var img = Globals.imageLoader.load_if_exists("user://note")
	if img:
		note_solid_mat.set_shader_param("image",img)
		note_transparent_mat.set_shader_param("image",img)
		note_solid_mat.set_shader_param("use_image",true)
		note_transparent_mat.set_shader_param("use_image",true)
	
	mesh.surface_set_material(0,note_solid_mat)
	if mesh.get_surface_count() > 1:
		mesh.surface_set_material(1,note_transparent_mat)
	if mesh.get_surface_count() > 2:
		mesh.surface_set_material(2,note_solid_mat)
		
	$Notes.multimesh.mesh = mesh
	
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
	$Notes.multimesh.set_instance_color(0,Color(0,0,0,0))
	$Notes.multimesh.set_instance_transform(0,Transform())
	if asq:
		$ASq.multimesh.set_instance_color(0,Color(0,0,0,0))
		$ASq.multimesh.set_instance_transform(0,Transform())
	$Note.visible = true
	$Note.transform.origin = Vector3(0,0,-400)
	yield(get_tree(),"idle_frame")
	$Note.visible = false
	
	# Precache notes
#	if SSP.visual_mode: # Precache a bunch of notes, because we're probably going to need them
#		for i in range(800):
#			var n = $Note.duplicate()
#			noteCache.append(n)
##			add_child(n)
#	else:
#		for i in range(25):
#			var n = $Note.duplicate()
#			noteCache.append(n)

var music_started:bool = false
const cursor_offset = Vector3(1,-1,0)
onready var cam:Camera = get_node("../..").get_node("Camera")
var hlpower = (0.1 * SSP.get("parallax"))
onready var Grid = get_node("../HUD")

func do_half_lock():
	var cursorpos = $Cursor.transform.origin
	if SSP.follow_drift_cursor:
		cursorpos += $Cursor/Mesh2.transform.origin
	var centeroff = cursorpos - cursor_offset
	var hlm = 0.25
	var uim = SSP.get("ui_parallax") * 0.1
	var grm = SSP.get("grid_parallax") * 0.1
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
	
	var hlm = 0.25
	var uim = SSP.get("ui_parallax") * 0.1
	var grm = SSP.get("grid_parallax") * 0.1
	Grid.transform.origin = Vector3(
		-centeroff.x*hlm*uim, -centeroff.y*hlm*uim, Grid.transform.origin.z
	)
	transform.origin = Vector3(
		-(centeroff.x*hlm*grm)-1, -(centeroff.y*hlm*grm)+1, 0
	)

func do_vr_cursor():
	var centeroff = SSP.vr_player.primary_ray.get_collision_point() + cursor_offset
	
	var cx = centeroff.x
	var cy = -centeroff.y
	cx = clamp(cx, (0 + sh.x + edgec), (3 + sh.x - edgec))
	cy = clamp(cy, (0 + sh.y + edgec), (3 + sh.y - edgec))
	centeroff.x = cx - cursor_offset.x
	centeroff.y = -cy - cursor_offset.y
	
	var hlm = 0.25
	var uim = SSP.get("ui_parallax") * 0.1
	var grm = SSP.get("grid_parallax") * 0.1
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

var spawn_ms_dist:float = ((max(SSP.get("spawn_distance") / SSP.get("approach_rate"),0.6) * 1000) + 500)

func do_note_queue():
	pass
	#	var rem:int = 0
	#	for n in noteQueue:
	#		if n[2] <= (ms + (spawn_ms_dist * speed_multi)):
	#			rem += 1
	#
	#			spawn_note(n)
	#			noteQueue.remove(noteQueue.find(n))
	#		else:
	#			break


var rec_t:float = 0
var rms:float = 0
var rec_interval:float = 12
var pause_state:float = 0
var pause_cooldown:float = 0
var pause_ms:float = 0
var replay_unpause:bool = false
var can_skip:bool = ((next_ms-prev_ms) > 5000) and (next_ms >= max(ms+(3000*speed_multi),1100*speed_multi))
var ms_offset:float = 0

var replay_sig:Array = []
var last_usec = OS.get_ticks_usec()

func _set_rec_interval(delta:float):
	var newpos = $Cursor.transform.origin
	var diff = last_cursor_position.distance_to(newpos)/delta
	
	var min_interval = 30
	var max_interval = 144
	match SSP.record_limit:
		1:
			min_interval = 60
			max_interval = 240
	if Engine.target_fps != 0:
		max_interval = min(max_interval,Engine.target_fps)
		min_interval = min(min_interval,max_interval)
	var target_interval = min_interval+((diff/12)*(max_interval-min_interval))
	var new_interval = rec_interval
	if rec_interval != target_interval:
		match SSP.record_mode:
			0:
				new_interval = target_interval
			1:
				if target_interval > rec_interval: new_interval += (target_interval-rec_interval) * (delta / 0.2)
				else: new_interval += (target_interval-rec_interval) * (delta / 2)
			2:
				if target_interval > rec_interval: new_interval += (target_interval-rec_interval) * (delta / 2)
				else: new_interval = target_interval
	rec_interval = clamp(new_interval,min_interval,max_interval)
	
	last_cursor_position = newpos

func _process(delta:float):
	var u = OS.get_ticks_usec()
	delta = float(u - last_usec) / 1_000_000.0
	last_usec = u
	
	if SSP.vr: do_vr_cursor()
	elif SSP.get("cam_unlock"): do_spin()
	else: do_half_lock()
	
	_set_rec_interval(delta)
	
	if active and notes_loaded:
		if !notes_loaded: return
		can_skip = ((next_ms-prev_ms) > 5000) and (next_ms >= max(ms+(3000*speed_multi),1100*speed_multi)) and ($Notes.multimesh.visible_instance_count <= 1)
		
		$Cursor.can_switch_move_modes = (ms < SSP.music_offset)
		
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
					ms = next_ms - 1000 - (1000*speed_multi)
					emit_signal("ms_change",ms)
					do_note_queue()
#					if (ms + SSP.music_offset) >= SSP.start_offset:
#						$Music.play((ms + SSP.music_offset)/1000)
#						music_started = true
				else:
					if pause_state == 0 and (ms > (1000 * speed_multi) and ms < get_parent().last_ms) and pause_cooldown == 0 and !SSP.disable_pausing:
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
					pause_cooldown = 1
			elif pause_state == 0:
				 pause_cooldown = max(pause_cooldown - delta, 0)
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
				if SSP.record_replays:
					SSP.replay.store_sig(rms,Globals.RS_SKIP)
				ms = next_ms - 1000 - (1000*speed_multi)
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
		rec_t += delta
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
			var ri = 1/round(max(32,rec_interval))
			if pause_state == -1: ri /= 3
			if rn_res or rec_t >= ri:
				rec_t = 0
				should_write_pos = true
				SSP.replay.store_cursor_pos(rms,$Cursor.rpos.x,$Cursor.rpos.y)
		
		if SSP.rainbow_grid:
			$Inner.get("material/0").albedo_color = Color.from_hsv(SSP.rainbow_t*0.1,0.65,1)
			$Outer.get("material/0").albedo_color = Color.from_hsv(SSP.rainbow_t*0.1,0.65,1)


func _exit_tree():
	# Remove anything sitting outside of the tree
	scoreEffect.queue_free()
	for n in noteCache:
		n.queue_free()
