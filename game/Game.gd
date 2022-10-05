extends Spatial

signal hit
signal miss

var rawMapData:String
var notes:Array
var last_ms:float = 0
onready var colors:Array = SSP.selected_colorset.colors

var score:int = 0

var last_combo:int = 0
var combo:int = 0
var combo_level:int = 1
var lvl_progress:int = 0

export(StyleBox) var timer_fg_done

func comma_sep(number):
	var string = str(number)
	var mod = string.length() % 3
	var res = ""
	
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]
	
	return res

func loadMapFile():
	var map:Song = SSP.selected_song
	last_ms = map.last_ms# / $Spawn.speed_multi
#	print(last_ms)
	if map.should_reload_on_play:
		map.setup_from_file(map.initFile,map.musicFile)
	notes = map.read_notes()
	var file:File = File.new()
	var song:AudioStream = map.stream()
	$Spawn.spawn_notes(notes)
	
	get_node("Spawn/Music").stream = song

onready var timebar:ProgressBar = get_node("Grid/TimerVP/Control/Time")
onready var timelabel:Label = get_node("Grid/TimerVP/Control/Label")
onready var songnametxt:Label = get_node("Grid/TimerVP/Control/SongName")
onready var acclabel:Label = get_node("Grid/LeftVP/Control/Accuracy")
onready var accbar:ProgressBar = get_node("Grid/LeftVP/Control/AccuracyBar")
onready var noteslabel:Label = get_node("Grid/RightVP/Control/Notes")
onready var misseslabel:Label = get_node("Grid/RightVP/Control/Misses")
onready var scorelabel:Label = get_node("Grid/RightVP/Control/Score")
onready var energybar:ProgressBar = get_node("Grid/EnergyVP/Control/Energy")
onready var modicons:HBoxContainer = get_node("Grid/EnergyVP/Control/Modifiers/Icons/H")
onready var modtxt:Label = get_node("Grid/EnergyVP/Control/Modifiers/Text")

onready var comboring:Control = get_node("Grid/LeftVP/Control/Combo")
onready var combotxt:Label = get_node("Grid/LeftVP/Control/Combo/Label")
onready var truecombo:Label = get_node("Grid/ComboVP/Value")

onready var friend:MeshInstance = get_node("Spawn/Friend")

onready var head:Spatial = get_node("Avatar/Head")

var hits:float = 0
var misses:float = 0
var total_notes:float = 0
var energy:float = 6
var max_energy:float = 6
var energy_per_hit:float = 1

var rainbow_letter_grade:bool = false

func update_hud():
	if hits == total_notes: acclabel.text = "100%"
	elif hits == 0: acclabel.text = "0%"
	else: acclabel.text = "%.3f%%" % ((hits/total_notes)*100)
	SSP.song_end_accuracy_str = acclabel.text
	accbar.value = hits/total_notes
	noteslabel.text = "%s/%s" % [comma_sep(hits),comma_sep(total_notes)]
	misseslabel.text = "%s" % comma_sep(misses)
	energybar.max_value = max_energy
	energybar.value = energy
	combotxt.text = String(combo_level) + "x"
	comboring._set_percent(float(lvl_progress) / 10)
	
	if combo != last_combo:
		truecombo.text = String(combo)
		truecombo.rect_position.y = 100
		last_combo = combo
	
	
	scorelabel.text = comma_sep(score)
	
	
	var grade:String = "--"
	var gcol:Color = Color(1,0,1)
	var shine:float = 0
	var acc = hits/total_notes
	rainbow_letter_grade = (acc == 1)
	if acc == 1:
		grade = "SS"
		gcol = Color.from_hsv(SSP.rainbow_t*0.1,0.4,1)
		shine = 1
	elif acc >= 0.98:
		grade = "S"
		gcol = Color("#91fffa")
		shine = 0.5
	elif acc >= 0.95:
		grade = "A"
		gcol = Color("#91ff92")
	elif acc >= 0.90:
		grade = "B"
		gcol = Color("#e7ffc0")
	elif acc >= 0.85:
		grade = "C"
		gcol = Color("#fcf7b3")
	elif acc >= 0.80:
		grade = "D"
		gcol = Color("#fcd0b3")
	else:
		grade = "F"
		gcol = Color("#ff8282")
	
	$Grid/LeftVP/Control/LetterGrade.text = grade
	$Grid/LeftVP/Control/LetterGrade.material.set_shader_param("amount",shine)
	if !SSP.rainbow_hud: $Grid/LeftVP/Control/LetterGrade.set("custom_colors/font_color",gcol)

var ending:bool = false
func end(end_type:int):
	if ending: return
	print("My god, what are you doing?!")
	ending = true
	if end_type == Globals.END_GIVEUP and SSP.record_replays and !SSP.replaying:
		SSP.replay.store_sig($Spawn.rms,Globals.RS_GIVEUP)
	if end_type != Globals.END_PASS:
		friend.failed = true
		SSP.fail_asp.play()
	friend.upd()
	get_tree().paused = true
	if total_notes == 0: total_notes = 1
	update_hud()
	SSP.just_ended_song = true
	SSP.song_end_hits = hits
	SSP.song_end_misses = misses
	SSP.song_end_total_notes = total_notes
	SSP.song_end_position = min($Spawn.ms,last_ms)
	SSP.song_end_length = last_ms
	SSP.song_end_type = end_type
	if SSP.record_replays and !SSP.replaying:
		SSP.replay.end_recording()
	
	if SSP.queue_active and end_type == Globals.END_PASS:
		if SSP.do_pb_check_and_set():
			Globals.notify(Globals.NOTIFY_SUCCEED,"new best!")
		var next = SSP.get_next()
		$Spawn.ms_offset += max($Spawn.ms - (SSP.start_offset - (3000 * $Spawn.speed_multi)), 0)
		if SSP.queue_active and next:
			$Spawn.ms = SSP.start_offset - (3000 * $Spawn.speed_multi)
			SSP.select_song(next)
			songnametxt.text = SSP.selected_song.name
			SSP.update_rpc_song()
			if SSP.record_replays and !SSP.replaying:
				SSP.replay = Replay.new()
				SSP.replay.start_recording(SSP.selected_song)
			
			$Spawn.notes_loaded = false
			$Spawn.chaos_rng = RandomNumberGenerator.new()
			$Spawn.chaos_rng.seed = hash(SSP.selected_song.id)
			$Spawn.music_started = false
			$Spawn.out_of_notes = false
			$Spawn.note_count = 0
			
			$Spawn.prev_ms = (SSP.start_offset - (3000 * $Spawn.speed_multi))
			$Spawn.next_ms = 0
			get_tree().paused = false
			$Spawn.emit_signal("ms_change",$Spawn.ms)
			loadMapFile()
			ending = false
			return
	
	black_fade_target = true
	yield(get_tree().create_timer(1),"timeout")
	
	get_tree().change_scene("res://menuload.tscn")

func update_timer(ms:float,canSkip:bool=false):
	var qms = ms + $Spawn.ms_offset
	var lms = last_ms
	
	if SSP.queue_active:
		lms = SSP.queue_end_length + (3000 * (SSP.song_queue.size() - 1))
	
	var s = clamp(floor(qms/1000),0,lms/1000)
	var m = floor(s / 60)
	var rs = fmod(s,60)
	
	var ls = floor(lms/1000)
	var lm = floor(ls / 60)
	var lrs = fmod(ls,60)
	
	timebar.value = clamp(qms/lms,0,1)
	if canSkip: timelabel.text = "PRESS SPACE TO SKIP"
	else: timelabel.text = "%d:%02d / %d:%02d" % [m,rs,lm,lrs]
	SSP.song_end_time_str = "%d:%02d" % [m,rs]
	
	if SSP.queue_active:
		if ms >= last_ms + SSP.hitwindow_ms:
			songnametxt.text = "(Intermission)"
			get_node("Spawn/Music").volume_db -= (17 * get_process_delta_time())
		else:
			get_node("Spawn/Music").volume_db = SSP.music_volume_db
			songnametxt.text = SSP.selected_song.name
	
	if ms >= last_ms + SSP.hitwindow_ms:
		if SSP.queue_active and ms >= last_ms + max(SSP.hitwindow_ms,3000):
			get_node("Spawn/Music").stop()
			end(Globals.END_PASS)
		elif !SSP.queue_active and !get_node("Spawn/Music").playing:
			end(Globals.END_PASS)


var loaded = false

var giving_up:float = 0
var black_fade_target:bool = false
var black_fade:float = 1
var config_time:float = 2.5
var passed:bool = false

func _process(delta):
	
	if SSP.show_config:
		config_time = max(config_time-delta,0)
		if config_time <= 0: $Grid/ConfigHud.visible = false
		else: $Grid/ConfigHud.opacity = min(1,config_time)
	
	if !SSP.queue_active and $Spawn.ms > last_ms:
		
		passed = true
		
		if $Grid/TimerVP/Control/Time.get("custom_styles/fg") != timer_fg_done:
			$Grid/TimerVP/Control/Time.set("custom_styles/fg",timer_fg_done)
			
		head.get_node("EyeL").visible = false
		head.get_node("HappyL").visible = true
			
		head.get_node("EyeR").visible = false
		head.get_node("HappyR").visible = true
		
	if passed:
		$Avatar/ArmR.translation.y += (1 - $Avatar/ArmR.translation.y) * 0.01
	
	if !ending:
		if Input.is_action_pressed("give_up"):
			giving_up += delta/0.6
			get_node("Grid/GiveUpHud").visible = true
			get_node("Grid/GiveUpVP/Control/Label").visible = !$Grid/PauseHud.visible
			if $Spawn.ms > last_ms:
				get_node("Grid/GiveUpVP/Control/Label").text = "Skipping..."
				get_node("Grid/GiveUpVP/Control").fill_color = Color("#81ff75")
			get_node("Grid/GiveUpVP/Control").percent = giving_up
			get_node("Grid/GiveUpHud").opacity = min(giving_up*2,1)
			if giving_up >= 1:
				if !SSP.queue_active and $Spawn.ms > last_ms: end(Globals.END_PASS)
				else: end(Globals.END_GIVEUP)
		else:
			get_node("Grid/GiveUpHud").visible = false
			get_node("Grid/GiveUpHud").opacity = 0
			giving_up = 0
	
	if misseslabel.modulate != Color(1,1,1):
		misseslabel.modulate.g = min(misseslabel.modulate.g+5*delta,1)
		misseslabel.modulate.b = min(misseslabel.modulate.b+5*delta,1)
	
	if SSP.replaying and Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
	
	if get_tree().paused:
		$Spawn.last_usec = OS.get_ticks_usec()
	
	if rainbow_letter_grade and !SSP.rainbow_hud:
		$Grid/LeftVP/Control/LetterGrade.set("custom_colors/font_color",Color.from_hsv(SSP.rainbow_t*0.1,0.4,1))
	
	if black_fade_target && black_fade != 1:
		black_fade = min(black_fade + (delta/0.75),1)
		$BlackFade.color = Color(0,0,0,black_fade)
	elif !black_fade_target && black_fade != 0:
		black_fade = max(black_fade - (delta/0.75),0)
		$BlackFade.color = Color(0,0,0,black_fade)
	
	$BlackFade.visible = (black_fade != 0)

func linstep(a:float,b:float,x:float):
	if a == b: return float(x >= a)
	return clamp(abs((x - a) / (b - a)),0,1)

func get_point_amt() -> int:
	var speed_multi = Globals.speed_multi[SSP.custom_speed]
	var spd = clamp(((speed_multi - 1) * 1.5) + 1, 0, 1.9)
	
	var hitbox_diff = SSP.note_hitbox_size - 1.140
	var hbo = clamp(linstep(1.140,0,hitbox_diff), 0, 1)
	
	var hitwin_diff = SSP.note_hitbox_size - 55
	var hwi = clamp(linstep(55,0,hitwin_diff), 0, 1)
	
	
	var mod = 1
	
	return int(floor((20 * combo_level * spd * min(hbo,hwi) * mod) + 0.5))


func hit(col):
	emit_signal("hit",col)
	hits += 1
	total_notes += 1
	if !SSP.mod_no_regen: energy = clamp(energy+energy_per_hit,0,max_energy)
	combo += 1
	var points = get_point_amt()
	if combo_level != 8:
		lvl_progress += 1
	if combo_level != 8 and lvl_progress == 10:
		lvl_progress = 0
		combo_level += 1
		if combo_level == 8: lvl_progress = 10
	update_hud()
	
	score += points
	return points

func miss(col):
	misseslabel.modulate = Color(1,0,0)
	emit_signal("miss",col)
	misses += 1
	total_notes += 1
	if !SSP.mod_nofail: energy = clamp(energy-1,0,max_energy)
	combo = 0
	lvl_progress = 0
	if combo_level != 1: combo_level -= 1
	update_hud()
	if energy == 0: end(Globals.END_FAIL)


func _ready():
	SSP.song_end_pause_count = 0
	SSP.song_end_misses = 0
	get_tree().paused = true
	get_node("Spawn/Music").volume_db = SSP.music_volume_db
	if SSP.mod_sudden_death:
		max_energy = 1
	elif SSP.health_model == Globals.HP_OLD:
		energy_per_hit = 1
		if SSP.mod_extra_energy: max_energy = 10
		else: max_energy = 6
	elif SSP.health_model == Globals.HP_SOUNDSPACE:
		energy_per_hit = 0.5
		if SSP.mod_extra_energy: max_energy = 8
		else: max_energy = 5
	
	energy = max_energy
#	var space = SSP.loaded_world
	var spinst = SSP.loaded_world.instance()
	get_parent().call_deferred("add_child",spinst)
	spinst.name = "Space"
#	call_deferred("raise")
	$BlackFade.color = Color(0,0,0,black_fade)
	get_tree().paused = false
	$Spawn.connect("timer_update",self,"update_timer")
#	$Spawn.connect("hit",self,"hit")
	$Spawn.connect("miss",self,"miss")
	loadMapFile()
	if !SSP.show_config: $Grid/ConfigHud.visible = false
	if !SSP.enable_grid: $Spawn/Inner.visible = false
	if !SSP.enable_border: $Spawn/Outer.visible = false
	if SSP.visual_mode or !SSP.show_left_panel: $Grid/LeftHud.visible = false
	if SSP.visual_mode or !SSP.show_right_panel: $Grid/RightHud.visible = false
	if !SSP.show_letter_grade: $Grid/LeftHud/Control/LetterGrade.visible = false
	if !SSP.show_accuracy_bar: $Grid/LeftVP/Control/AccuracyBar.visible = false
	if SSP.visual_mode or !SSP.show_hp_bar:
		$Grid/EnergyVP/Control/Energy.visible = false
		$Grid/EnergyVP/Control/Modifiers.margin_top -= 30
	if !SSP.show_timer: $Grid/TimerHud.visible = false
	if SSP.attach_hp_to_grid:
		var eh = $Grid/EnergyHud
		$Grid.remove_child(eh)
		$Spawn.add_child(eh)
		eh.transform.origin += Vector3(1,-1,0)
	if SSP.attach_timer_to_grid:
		var th = $Grid/TimerHud
		$Grid.remove_child(th)
		$Spawn.add_child(th)
		th.transform.origin += Vector3(1,-1,0)
	if SSP.simple_hud:
		$Grid/LeftVP/Control.color = Color(0,0,0,0)
		$Grid/RightVP/Control.color = Color(0,0,0,0)
		
		for n in $Grid/LeftVP/Control.get_children():
			n.visible = n.name == "SimpleBg" or n.name == "Pauses" or n.name == "PausesTitle"
			if n.visible: n.rect_position.y += 100
		for n in $Grid/RightVP/Control.get_children():
			n.visible = n.name == "SimpleBg" or n.name == "Misses" or n.name == "MissesTitle"
			if n.visible: n.rect_position.y += 100
	if SSP.faraway_hud:
		$Grid.transform.origin = Vector3(0,0,-10)
		$Grid.scale = Vector3(3.7,3.7,3.7)
	if SSP.visual_mode:
		$Grid/EnergyVP/Control/Modifiers.visible = false
		
	songnametxt.text = SSP.selected_song.name

	
	var ms = ""
	
	if SSP.replaying:
		if SSP.replay.autoplayer: modicons.get_node("Autoplay").visible = true
		else: modicons.get_node("Replaying").visible = true
	
	if SSP.mod_nofail: ms += "[ NOFAIL ACTIVE ]\n"
	elif SSP.health_model == Globals.HP_OLD: ms += "Using old hp model (more hp + fast regen)\n"
	
	var mods = []
	if SSP.mod_speed_level != Globals.SPEED_NORMAL:
		match SSP.mod_speed_level:
			Globals.SPEED_MMM: modicons.get_node("SpeedMMM").visible = true
			Globals.SPEED_MM: modicons.get_node("SpeedMM").visible = true
			Globals.SPEED_M: modicons.get_node("SpeedM").visible = true
			Globals.SPEED_P: modicons.get_node("SpeedP").visible = true
			Globals.SPEED_PP: modicons.get_node("SpeedPP").visible = true
			Globals.SPEED_PPP: modicons.get_node("SpeedPPP").visible = true
			Globals.SPEED_PPPP: modicons.get_node("SpeedPPPP").visible = true
			Globals.SPEED_CUSTOM: mods.append("Speed%s%%" % [Globals.speed_multi[Globals.SPEED_CUSTOM] * 100])
	if SSP.mod_sudden_death: mods.append("SuddenDeath")
	if SSP.mod_extra_energy: mods.append("Energy+")
	if SSP.mod_no_regen: mods.append("NoRegen")
	if SSP.mod_mirror_x or SSP.mod_mirror_y:
		var mirrorst = "Mirror"
		if SSP.mod_mirror_x: mirrorst += "X"
		if SSP.mod_mirror_y: mirrorst += "Y"
		mods.append(mirrorst)
	if SSP.mod_ghost: mods.append("Ghost")
	if SSP.mod_nearsighted: mods.append("Nearsight")
	if SSP.mod_chaos: mods.append("Chaos")
	for i in range(mods.size()):
		if i != 0: ms += " "
		ms += mods[i]
	if mods.size() != 0 and !SSP.mod_nofail: ms += '\n'
	
	if SSP.hitwindow_ms != 55 or SSP.note_hitbox_size != 1.140:
		ms += "HW: %.0f ms | HB: %.02f m" % [SSP.hitwindow_ms,SSP.note_hitbox_size]
	
	modtxt.text = ms
	
	if SSP.rainbow_hud:
		comboring.fill_color = Color(1,1,1)
		comboring.empty_color = Color(0.2,0.2,0.2,0.75)
		accbar.get("custom_styles/fg").bg_color = Color(1,1,1)
		accbar.get("custom_styles/bg").bg_color = Color(0.2,0.2,0.2,0.75)
	
	SSP.update_rpc_song()

