extends Spatial

signal hit
signal miss

var rawMapData:String
var notes:Array
var last_ms:float = 0
onready var colors:Array = SSP.selected_colorset.colors

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
	get_node("Spawn/Music").stream = song
	$Spawn.spawn_notes(notes)

onready var timebar:ProgressBar = get_node("Grid/TimerVP/Control/Time")
onready var timelabel:Label = get_node("Grid/TimerVP/Control/Label")
onready var songnametxt:Label = get_node("Grid/TimerVP/Control/SongName")
onready var acclabel:Label = get_node("Grid/LeftVP/Control/Accuracy")
onready var accbar:ProgressBar = get_node("Grid/LeftVP/Control/AccuracyBar")
onready var noteslabel:Label = get_node("Grid/RightVP/Control/Notes")
onready var misseslabel:Label = get_node("Grid/RightVP/Control/Misses")
onready var energybar:ProgressBar = get_node("Grid/EnergyVP/Control/Energy")
onready var modtxt:Label = get_node("Grid/EnergyVP/Control/Modifiers")

onready var comboring:Control = get_node("Grid/LeftVP/Control/Combo")
onready var combotxt:Label = get_node("Grid/LeftVP/Control/Combo/Label")
onready var truecombo:Label = get_node("Grid/ComboVP/Value")

var hits:float = 0
var misses:float = 0
var total_notes:float = 0
var energy:float = 6
var max_energy:float = 6
var energy_per_hit:float = 1

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
	comboring._set_percent(float(lvl_progress) / 8)
	
	truecombo.text = String(combo)
	truecombo.rect_position.y = 100

var ending:bool = false
func end(end_type:int):
	if ending: return
	ending = true
	if end_type != Globals.END_PASS: SSP.fail_asp.play()
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
	black_fade_target = true
	yield(get_tree().create_timer(1),"timeout")
	get_tree().change_scene("res://menuload.tscn")

func update_timer(ms:float):
	var s = clamp(floor(ms/1000),0,last_ms/1000)
	var m = floor(s / 60)
	var rs = fmod(s,60)
	timebar.value = clamp(ms/last_ms,0,1)
	timelabel.text = "%d:%02d" % [m,rs]
	SSP.song_end_time_str = timelabel.text
	if ms >= last_ms:
#		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if get_node("Spawn/Music").playing:
			yield(get_node("Spawn/Music"),"finished")
		end(Globals.END_PASS)
#		get_tree().quit()


var loaded = false

var giving_up:float = 0
var black_fade_target:bool = false
var black_fade:float = 1
var config_time:float = 2.5

func _process(delta):
	if SSP.show_config:
		config_time = max(config_time-delta,0)
		if config_time <= 0: $Grid/ConfigHud.visible = false
		else: $Grid/ConfigHud.opacity = min(1,config_time)
	
	if $Spawn.ms > last_ms:
		if $Grid/TimerVP/Control/Time.get("custom_styles/fg") != timer_fg_done:
			$Grid/TimerVP/Control/Time.set("custom_styles/fg",timer_fg_done)
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
				if $Spawn.ms > last_ms: end(Globals.END_PASS)
				else: end(Globals.END_GIVEUP)
		else:
			get_node("Grid/GiveUpHud").visible = false
			get_node("Grid/GiveUpHud").opacity = 0
			giving_up = 0
	
	if misseslabel.modulate != Color(1,1,1):
		misseslabel.modulate.g = min(misseslabel.modulate.g+5*delta,1)
		misseslabel.modulate.b = min(misseslabel.modulate.b+5*delta,1)
	
	if black_fade_target && black_fade != 1:
		black_fade = min(black_fade + (delta/0.75),1)
		$BlackFade.color = Color(0,0,0,black_fade)
	elif !black_fade_target && black_fade != 0:
		black_fade = max(black_fade - (delta/0.75),0)
		$BlackFade.color = Color(0,0,0,black_fade)


func hit(col):
	emit_signal("hit",col)
	hits += 1
	total_notes += 1
	if !SSP.mod_no_regen: energy = clamp(energy+energy_per_hit,0,max_energy)
	combo += 1
	if combo_level != 8 or (combo_level == 8 and lvl_progress != 8):
		lvl_progress += 1
	if combo_level != 8 and lvl_progress == 8:
		lvl_progress = 0
		combo_level += 1
	update_hud()

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
	get_tree().paused = true
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
	$Spawn.connect("ms_change",self,"update_timer")
	$Spawn.connect("hit",self,"hit")
	$Spawn.connect("miss",self,"miss")
	loadMapFile()
	if !SSP.show_config: $Grid/ConfigHud.visible = false
	if !SSP.enable_grid: $Spawn/Inner.visible = false
	if !SSP.enable_border: $Spawn/Outer.visible = false
	songnametxt.text = SSP.selected_song.name
	
	var ms = ""
	
	if SSP.mod_nofail: ms = "[ NOFAIL ACTIVE ]\n"
	elif SSP.health_model == Globals.HP_OLD: ms = "Using old hp model (more hp + fast regen)\n"
	
	var mods = []
	if SSP.mod_speed_level != Globals.SPEED_NORMAL:
		match SSP.mod_speed_level:
			Globals.SPEED_MMM: mods.append("Speed---")
			Globals.SPEED_MM: mods.append("Speed--")
			Globals.SPEED_M: mods.append("Speed-")
			Globals.SPEED_P: mods.append("Speed+")
			Globals.SPEED_PP: mods.append("Speed++")
			Globals.SPEED_PPP: mods.append("Speed+++")
			Globals.SPEED_CUSTOM: mods.append("Speed%.01f%%" % Globals.speed_multi[Globals.SPEED_CUSTOM]*100)
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
	for i in range(mods.size()):
		if i != 0: ms += " "
		ms += mods[i]
	if mods.size() != 0 and !SSP.mod_nofail: ms += '\n'
	
	if SSP.hitwindow_ms != 55 or SSP.note_hitbox_size != 1.27:
		ms += "Hitwindow: %.0f ms | Hitboxes: %.02f m" % [SSP.hitwindow_ms,SSP.note_hitbox_size]
	
	modtxt.text = ms
