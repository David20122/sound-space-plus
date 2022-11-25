extends Spatial


onready var Game:SongPlayerManager = get_parent()
onready var Spawn:NoteManager = get_parent().get_node("Spawn")


onready var timebar:ProgressBar = get_node("TimerVP/Control/Time")
onready var timelabel:Label = get_node("TimerVP/Control/Label")
onready var songnametxt:Label = get_node("TimerVP/Control/SongName")
onready var acclabel:Label = get_node("LeftVP/Control/Accuracy")
onready var accbar:ProgressBar = get_node("LeftVP/Control/AccuracyBar")
onready var pauselabel:Label = get_node("LeftVP/Control/Pauses")
onready var noteslabel:Label = get_node("RightVP/Control/Notes")
onready var misseslabel:Label = get_node("RightVP/Control/Misses")
onready var scorelabel:Label = get_node("RightVP/Control/Score")
onready var energybar:ProgressBar = get_node("EnergyVP/Control/Energy")
onready var modicons:HBoxContainer = get_node("EnergyVP/Control/Modifiers/Icons/H")
onready var modtxt:Label = get_node("EnergyVP/Control/Modifiers/Text")

onready var comboring:Control = get_node("LeftVP/Control/Combo")
onready var combotxt:Label = get_node("LeftVP/Control/Combo/Label")
onready var truecombo:Label = get_node("ComboVP/Value")

onready var lettergrade:Label = get_node("LeftVP/Control/LetterGrade")

onready var friend:MeshInstance = Spawn.get_node("Friend")




var panel_bg:Color = SSP.panel_bg
var panel_text:Color = SSP.panel_text

var unpause_fill_color:Color = SSP.unpause_fill_color
var unpause_empty_color:Color = SSP.unpause_empty_color
var how_to_quit:Color = SSP.how_to_quit

var combo_fill_color:Color = SSP.combo_fill_color
var combo_empty_color:Color = SSP.combo_empty_color

var acc_fill_color:Color = SSP.acc_fill_color
var acc_empty_color:Color = SSP.acc_empty_color

var giveup_text:Color = SSP.giveup_text
var giveup_fill_color:Color = SSP.giveup_fill_color
var giveup_fill_color_end_skip:Color = SSP.giveup_fill_color_end_skip

var timer_text:Color = SSP.timer_text
var timer_text_done:Color = SSP.timer_text_done
var timer_text_canskip:Color = SSP.timer_text_canskip

var timer_fg:Color = SSP.timer_fg
var timer_bg:Color = SSP.timer_bg
var timer_fg_done:Color = SSP.timer_fg_done
var timer_bg_done:Color = SSP.timer_bg_done
var timer_fg_canskip:Color = SSP.timer_fg_canskip
var timer_bg_canskip:Color = SSP.timer_bg_canskip

var miss_flash_color:Color = SSP.miss_flash_color
var pause_used_color:Color = SSP.pause_used_color

var miss_text_color:Color = SSP.miss_text_color
var pause_text_color:Color = SSP.pause_text_color
var score_text_color:Color = SSP.score_text_color

var pause_ui_opacity:float = SSP.pause_ui_opacity

var grade_ss_saturation:float = SSP.grade_ss_saturation
var grade_ss_value:float = SSP.grade_ss_value
var grade_ss_shine:float = SSP.grade_ss_shine

var grade_s_color:Color = SSP.grade_s_color
var grade_s_shine:float = SSP.grade_s_shine

var grade_a_color:Color = SSP.grade_a_color
var grade_b_color:Color = SSP.grade_b_color
var grade_c_color:Color = SSP.grade_c_color
var grade_d_color:Color = SSP.grade_d_color
var grade_f_color:Color = SSP.grade_f_color



var last_combo:int = 0
var rainbow_letter_grade:bool = false

func set_song_name(name:String=SSP.selected_song.name):
	songnametxt.text = name

func song_end(end_type:int):
	if end_type == Globals.END_GIVEUP and SSP.record_replays and !SSP.replaying:
		SSP.replay.store_sig(Spawn.rms,Globals.RS_GIVEUP)
	if end_type != Globals.END_PASS:
		friend.failed = true
		SSP.fail_asp.play()
	friend.upd()

var combo_ring_target:float = 0
var combo_ring_value:float = 0

func update_static_values():

	if Game.hits == Game.total_notes: acclabel.text = "100%"
	elif Game.hits == 0: acclabel.text = "0%"
	else: acclabel.text = "%.3f%%" % ((Game.hits/Game.total_notes)*100)
	SSP.song_end_accuracy_str = acclabel.text
	if not Game.total_notes == 0:
		accbar.value = Game.hits/Game.total_notes
	noteslabel.text = "%s/%s" % [Globals.comma_sep(Game.hits),Globals.comma_sep(Game.total_notes)]
	misseslabel.text = "%s" % Globals.comma_sep(Game.misses)
	energybar.max_value = Game.max_energy
	energybar.value = Game.energy
	combotxt.text = String(Game.combo_level) + "x"
	combo_ring_target = float(Game.lvl_progress) / 10.0
	
	if Game.combo != last_combo:
		truecombo.text = String(Game.combo)
		truecombo.rect_position.y = 100
		last_combo = Game.combo
	
	pauselabel.text = Globals.comma_sep(SSP.song_end_pause_count)
	
	for n in get_tree().get_nodes_in_group("pause_text"):
		paint(
			n,
			pause_text_color if (SSP.song_end_pause_count == 0)
			else pause_used_color
		)
	
	scorelabel.text = Globals.comma_sep(Game.score)
	
	
	var grade:String = "--"
	var gcol:Color = Color(1,0,1)
	var shine:float = 0
	var acc = 100
	if not Game.total_notes == 0:
		acc = Game.hits/Game.total_notes
	rainbow_letter_grade = (acc == 1)
	if acc == 1:
		grade = "SS"
		gcol = Color.from_hsv(SSP.rainbow_t*0.1, grade_ss_saturation, grade_ss_value)
		shine = grade_ss_shine
	elif acc >= 0.98:
		grade = "S"
		gcol = grade_s_color
		shine = grade_s_shine
	elif acc >= 0.95:
		grade = "A"
		gcol = grade_a_color
	elif acc >= 0.90:
		grade = "B"
		gcol = grade_b_color
	elif acc >= 0.85:
		grade = "C"
		gcol = grade_c_color
	elif acc >= 0.80:
		grade = "D"
		gcol = grade_d_color
	else:
		grade = "F"
		gcol = grade_f_color
	
	lettergrade.text = grade
	if shine != lettergrade.material.get_shader_param("amount"):
		lettergrade.material.set_shader_param("amount",shine)
	
	if !SSP.rainbow_hud:
		lettergrade.set("custom_colors/font_color",gcol)

var miss_flash:float = 0

func update_timer(ms:float,canSkip:bool=false):
	var qms = ms + Spawn.ms_offset
	var lms = Game.last_ms
	
	if SSP.queue_active:
		lms = SSP.queue_end_length + (3000 * (SSP.song_queue.size() - 1))
	
	var s = clamp(floor(qms/1000),0,lms/1000)
	var m = floor(s / 60)
	var rs = fmod(s,60)
	
	var ls = floor(lms/1000)
	var lm = floor(ls / 60)
	var lrs = fmod(ls,60)
	
	if !SSP.rainbow_hud:
		if canSkip:
			timebar.get("custom_styles/fg").bg_color = timer_fg_canskip
			timebar.get("custom_styles/bg").bg_color = timer_bg_canskip
			for n in get_tree().get_nodes_in_group("timer_text"):
				paint(n,timer_text_canskip)
			
		elif !SSP.queue_active and Spawn.ms > Game.last_ms:
			timebar.get("custom_styles/fg").bg_color = timer_fg_done
			timebar.get("custom_styles/bg").bg_color = timer_bg_done
			for n in get_tree().get_nodes_in_group("timer_text"):
				paint(n,timer_text_done)
			
		else:
			timebar.get("custom_styles/fg").bg_color = timer_fg
			timebar.get("custom_styles/bg").bg_color = timer_bg
			for n in get_tree().get_nodes_in_group("timer_text"):
				paint(n,timer_text)
	
	timebar.value = clamp(qms/lms,0,1)
	if canSkip: timelabel.text = "PRESS SPACE TO SKIP"
	else: timelabel.text = "%d:%02d / %d:%02d" % [m,rs,lm,lrs]
	SSP.song_end_time_str = "%d:%02d" % [m,rs]
	
	if SSP.queue_active:
		if ms >= Game.last_ms + SSP.hitwindow_ms:
			songnametxt.text = "(Intermission)"
		else:
			songnametxt.text = SSP.selected_song.name

func on_miss(color:Color):
	miss_flash = 1

func paint(node:Control,color:Color):
	if node is ColorRect:
		node.color = color
	
	elif node is Panel:
		node.get("custom_styles/panel").bg_color = color
	
	elif node is Label:
		if node.has_color_override("font_color"):
			node.set("custom_colors/font_color",color)
		else:
			node.modulate = color
	
	else:
		node.modulate = color

var config_time:float = 2.5

func _process(delta:float):
	if SSP.show_config:
		config_time = max(config_time-delta,0)
		if config_time <= 0: $ConfigHud.visible = false
		else: $ConfigHud.opacity = min(1,config_time)
	
	if combo_ring_value > combo_ring_target:
		combo_ring_value = max(combo_ring_value + (
			((combo_ring_target - combo_ring_value) * delta * 6)
		), combo_ring_target)
	elif combo_ring_value < combo_ring_target:
		combo_ring_value = min(combo_ring_value + (
			((combo_ring_target - combo_ring_value) * delta * 6)
		), combo_ring_target)
	
	if comboring.percent != combo_ring_value:
		comboring._set_percent(combo_ring_value)
	
	if Input.is_action_pressed("give_up"):
		get_node("GiveUpHud").visible = true
		get_node("GiveUpVP/Control/Label").visible = !$PauseHud.visible
		if Spawn.ms > Game.last_ms:
			get_node("GiveUpVP/Control/Label").text = "Skipping..."
			get_node("GiveUpVP/Control").fill_color = giveup_fill_color_end_skip
			
		get_node("GiveUpVP/Control").percent = Game.giving_up
		get_node("GiveUpHud").opacity = min(Game.giving_up*2,1)
	else:
		get_node("GiveUpHud").visible = false
		get_node("GiveUpHud").opacity = 0
	
	if rainbow_letter_grade and !SSP.rainbow_hud:
		lettergrade.set("custom_colors/font_color",Color.from_hsv(SSP.rainbow_t*0.1, grade_ss_saturation, grade_ss_value))
	
	if miss_flash != 0:
		var miss_col = lerp(miss_text_color, miss_flash_color, miss_flash)
		for n in get_tree().get_nodes_in_group("miss_text"):
			paint(n, miss_col)
		miss_flash = max(0, miss_flash - (delta * 3))
	
	if SSP.rainbow_hud:
		energybar.get("custom_styles/fg").bg_color = Color.from_hsv(SSP.rainbow_t*0.1,0.4,1)
		energybar.get("custom_styles/bg").bg_color = Color.from_hsv(SSP.rainbow_t*0.1,0.4,0.2,0.65)
		$TimerHud.modulate = Color.from_hsv(SSP.rainbow_t*0.1,0.4,1)
		$ComboHud.modulate = Color.from_hsv(SSP.rainbow_t*0.1,0.4,1)
		$LeftHud.modulate = Color.from_hsv(SSP.rainbow_t*0.1,0.4,1)
		$RightHud.modulate = Color.from_hsv(SSP.rainbow_t*0.1,0.4,1)
	
	if Spawn.pause_state != 0:
		$PauseHud.visible = !Input.is_key_pressed(KEY_C)
		$PauseVP/Control.percent = clamp(
			1 - (Spawn.pause_state),
			0,
			float(Spawn.pause_state != -1)
		)
		$PauseHud.modulate = Color(1,1,1,abs(Spawn.pause_state) * pause_ui_opacity)
	else:
		$PauseHud.visible = false



func _ready():
	Game.connect("miss",self,"on_miss")
	
	$GiveUpVP/Control.fill_color = giveup_fill_color
	
	for n in get_tree().get_nodes_in_group("panel_bg"):
		paint(n,panel_bg)
	
	for n in get_tree().get_nodes_in_group("panel_text"):
		paint(n,panel_text)
	
	for n in get_tree().get_nodes_in_group("score_text"):
		paint(n,score_text_color)
	
	for n in get_tree().get_nodes_in_group("pause_text"):
		paint(n, pause_text_color)
	
	for n in get_tree().get_nodes_in_group("miss_text"):
		paint(n, miss_text_color)
	
	paint($PauseVP/Control/Paused,unpause_empty_color)
	paint($PauseVP/Control/ProgressBar/Paused,unpause_fill_color)
	paint($PauseVP/Control/HoldR,how_to_quit)
	paint($GiveUpVP/Control/Label,giveup_text)
	
	if SSP.rainbow_hud:
		var cf = max(max(combo_fill_color.r,combo_fill_color.g),combo_fill_color.b)
		var ce = max(max(combo_empty_color.r,combo_empty_color.g),combo_empty_color.b)
		var af = max(max(acc_fill_color.r,acc_fill_color.g),acc_fill_color.b)
		var ae = max(max(acc_empty_color.r,acc_empty_color.g),acc_empty_color.b)
		
		comboring.fill_color = Color(cf,cf,cf,combo_fill_color.a)
		comboring.empty_color = Color(ce,ce,ce,combo_empty_color.a)
		accbar.get("custom_styles/fg").bg_color = Color(af,af,af,acc_fill_color.a)
		accbar.get("custom_styles/bg").bg_color = Color(ae,ae,ae,acc_empty_color.a)
	else:
		comboring.fill_color = combo_fill_color
		comboring.empty_color = combo_empty_color
		accbar.get("custom_styles/fg").bg_color = acc_fill_color
		accbar.get("custom_styles/bg").bg_color = acc_empty_color
	
	
	
	if !SSP.show_config:
		$ConfigHud.visible = false
	
	if !SSP.enable_grid:
		Spawn.get_node("Inner").visible = false
	
	if !SSP.enable_border:
		Spawn.get_node("Outer").visible = false
	
	if SSP.visual_mode or !SSP.show_left_panel:
		$LeftHud.visible = false
	
	if SSP.visual_mode or !SSP.show_right_panel:
		$RightHud.visible = false
	
	if !SSP.show_letter_grade:
		lettergrade.visible = false
	
	if !SSP.show_accuracy_bar:
		accbar.visible = false
	
	if SSP.visual_mode or !SSP.show_hp_bar:
		energybar.visible = false
		$EnergyVP/Control/Modifiers.margin_top -= 30
	
	if !SSP.show_timer:
		$TimerHud.visible = false
	
	if SSP.attach_hp_to_grid:
		var eh = $EnergyHud
		remove_child(eh)
		Spawn.add_child(eh)
		eh.transform.origin += Vector3(1,-1,0)
	
	if SSP.attach_timer_to_grid:
		var th = $TimerHud
		remove_child(th)
		Spawn.add_child(th)
		th.transform.origin += Vector3(1,-1,0)
	
	if SSP.simple_hud:
		$LeftVP/Control.self_modulate = Color(0,0,0,0)
		$RightVP/Control.self_modulate = Color(0,0,0,0)
		
		for n in $LeftVP/Control.get_children():
			n.visible = n.name == "SimpleBg" or n.name == "Pauses" or n.name == "PausesTitle"
			if n.visible: n.rect_position.y += 100
		
		for n in $RightVP/Control.get_children():
			n.visible = n.name == "SimpleBg" or n.name == "Misses" or n.name == "MissesTitle"
			if n.visible: n.rect_position.y += 100
		
	if SSP.faraway_hud:
		transform.origin = Vector3(0,0,-10)
		scale = Vector3(3.7,3.7,3.7)
	
	if SSP.visual_mode:
		$EnergyVP/Control/Modifiers.visible = false
	
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
	if SSP.hitwindow_ms == 83 and SSP.note_hitbox_size == 1.710:
		ms = "py's nerf"
	if SSP.hitwindow_ms == 58 and SSP.note_hitbox_size == 1.140:
		ms = "Vulnus Judgement"
	if SSP.hitwindow_ms == 82 and SSP.note_hitbox_size == 1.700:
		ms = ""
	
	modtxt.text = ms



