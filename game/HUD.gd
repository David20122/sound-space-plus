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

onready var cur_pos = $"../Spawn/Cursor/Mesh".global_transform.origin
onready var pcur_pos = cur_pos




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



var elapsed:float = 0
var gtimer:float = 0 # global delta timer
var s_curspd:float = 0
var s_tcurspd:float = 0
var calculating:bool = false


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
	elif canSkip and OS.has_feature("Android"): timelabel.text = "TAP TO SKIP"
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
	gtimer += delta
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
	
	# stat mod
	elapsed += delta
	if elapsed >= 0.1 and calculating:
		pcur_pos = cur_pos
		cur_pos = $"../Spawn/Cursor/Mesh".global_transform.origin
		var dist = cur_pos.distance_to(pcur_pos)
		s_curspd = dist / elapsed
		if s_curspd > s_tcurspd:
			s_tcurspd = s_curspd
		elapsed = 0
	if gtimer >= 2:
		calculating = true
	
	var fstr = "cursor speed\n{current} m/sec/{frames}fr\n\ntop speed\n{top} m/sec/{frames}fr\n\nrec interval\n{rec}"
	$Stats/Label.text = fstr.format(
		{
			"current": stepify(s_curspd,0.1),
			"frames": Engine.get_frames_per_second(),
			"top": stepify(s_tcurspd,0.1),
			"rec": round(Spawn.rec_interval)
		}
	)
	
	# warning
	if SSP.get("fov") < 70 and SSP.mod_flashlight and calculating:
		$ObnoxiousWarning.trigger = true
		$ObnoxiousWarning.target = "STOP PLAYING MASKED WITH {fov} FOV PUSSY\njust use the damn default man".format({
			"fov": SSP.get("fov")
		})
	



func _ready():
	Game.connect("miss",self,"on_miss")
	
	$Stats/Label.visible = SSP.show_stats
	
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
			Globals.SPEED_CUSTOM: mods.append("S%s" % [Globals.speed_multi[Globals.SPEED_CUSTOM] * 100])
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
	if SSP.mod_earthquake: mods.append("Earthquake")
	if SSP.mod_flashlight: mods.append("Masked")
	if SSP.invert_mouse: mods.append("Mouse Inverted")
	for i in range(mods.size()):
		if i != 0: ms += " "
		ms += mods[i]
	if mods.size() != 0 and !SSP.mod_nofail: ms += '\n'
	
	if SSP.hitwindow_ms == 83 and SSP.note_hitbox_size == 1.710:
		ms += "py's nerf"
	elif SSP.hitwindow_ms == 58 and SSP.note_hitbox_size == 1.140:
		ms += "Vulnus Judgement"
	elif SSP.hitwindow_ms == 700 and SSP.note_hitbox_size == 3:
		ms += "Pyrecision Mode"
	elif SSP.hitwindow_ms != 55 or SSP.note_hitbox_size != 1.140:
		ms += "HW: %.0f ms | HB: %.02f m" % [SSP.hitwindow_ms,SSP.note_hitbox_size]
	
	modtxt.text = ms

#	Introduction
#
#	1. The Industrial Revolution and its consequences have been a disaster for the human race. They have greatly increased the life-expectancy of those of us who live in "advanced" countries, but they have destabilized society, have made life unfulfilling, have subjected human beings to indignities, have led to widespread psychological suffering (in the Third World to physical suffering as well) and have inflicted severe damage on the natural world. The continued development of technology will worsen the situation. It will certainly subject human beings to greater indignities and inflict greater damage on the natural world, it will probably lead to greater social disruption and psychological suffering, and it may lead to increased physical suffering even in "advanced" countries.
#	
#	2. The industrial-technological system may survive or it may break down. If it survives, it MAY eventually achieve a low level of physical and psychological suffering, but only after passing through a long and very painful period of adjustment and only at the cost of permanently reducing human beings and many other living organisms to engineered products and mere cogs in the social machine. Furthermore, if the system survives, the consequences will be inevitable: There is no way of reforming or modifying the system so as to prevent it from depriving people of dignity and autonomy.
#	
#	3. If the system breaks down the consequences will still be very painful. But the bigger the system grows the more disastrous the results of its breakdown will be, so if it is to break down it had best break down sooner rather than later.
#	
#	4. We therefore advocate a revolution against the industrial system. This revolution may or may not make use of violence; it may be sudden or it may be a relatively gradual process spanning a few decades. We can't predict any of that. But we do outline in a very general way the measures that those who hate the industrial system should take in order to prepare the way for a revolution against that form of society. This is not to be a POLITICAL revolution. Its object will be to overthrow not governments but the economic and technological basis of the present society.
#	
#	5. In this article we give attention to only some of the negative developments that have grown out of the industrial-technological system. Other such developments we mention only briefly or ignore altogether. This does not mean that we regard these other developments as unimportant. For practical reasons we have to confine our discussion to areas that have received insufficient public attention or in which we have something new to say. For example, since there are well-developed environmental and wilderness movements, we have written very little about environmental degradation or the destruction of wild nature, even though we consider these to be highly important.
#	
#	THE PSYCHOLOGY OF MODERN LEFTISM
#	
#	6. Almost everyone will agree that we live in a deeply troubled society. One of the most widespread manifestations of the craziness of our world is leftism, so a discussion of the psychology of leftism can serve as an introduction to the discussion of the problems of modern society in general.
#	
#	7. But what is leftism? During the first half of the 20th century leftism could have been practically identified with socialism. Today the movement is fragmented and it is not clear who can properly be called a leftist. When we speak of leftists in this article we have in mind mainly socialists, collectivists, "politically correct" types, feminists, gay and disability activists, animal rights activists and the like. But not everyone who is associated with one of these movements is a leftist. What we are trying to get at in discussing leftism is not so much movement or an ideology as a psychological type, or rather a collection of related types. Thus, what we mean by "leftism" will emerge more clearly in the course of our discussion of leftist psychology. (Also, see paragraphs 227-230.)
#	
#	8. Even so, our conception of leftism will remain a good deal less clear than we would wish, but there doesn't seem to be any remedy for this. All we are trying to do here is indicate in a rough and approximate way the two psychological tendencies that we believe are the main driving force of modern leftism. We by no means claim to be telling the WHOLE truth about leftist psychology. Also, our discussion is meant to apply to modern leftism only. We leave open the question of the extent to which our discussion could be applied to the leftists of the 19th and early 20th centuries.
#	
#	9. The two psychological tendencies that underlie modern leftism we call "feelings of inferiority" and "oversocialization." Feelings of inferiority are characteristic of modern leftism as a whole, while oversocialization is characteristic only of a certain segment of modern leftism; but this segment is highly influential.
#	
#	FEELINGS OF INFERIORITY
#	
#	10. By "feelings of inferiority" we mean not only inferiority feelings in the strict sense but a whole spectrum of related traits; low self-esteem, feelings of powerlessness, depressive tendencies, defeatism, guilt, self-hatred, etc. We argue that modern leftists tend to have some such feelings (possibly more or less repressed) and that these feelings are decisive in determining the direction of modern leftism.
#	
#	11. When someone interprets as derogatory almost anything that is said about him (or about groups with whom he identifies) we conclude that he has inferiority feelings or low self-esteem. This tendency is pronounced among minority rights activists, whether or not they belong to the minority groups whose rights they defend. They are hypersensitive about the words used to designate minorities and about anything that is said concerning minorities. The terms "negro," "oriental," "handicapped" or "chick" for an African, an Asian, a disabled person or a woman originally had no derogatory connotation. "Broad" and "chick" were merely the feminine equivalents of "guy," "dude" or "fellow." The negative connotations have been attached to these terms by the activists themselves. Some animal rights activists have gone so far as to reject the word "pet" and insist on its replacement by "animal companion." Leftish anthropologists go to great lengths to avoid saying anything about primitive peoples that could conceivably be interpreted as negative. They want to replace the world "primitive" by "nonliterate." They seem almost paranoid about anything that might suggest that any primitive culture is inferior to our own. (We do not mean to imply that primitive cultures ARE inferior to ours. We merely point out the hypersensitivity of leftish anthropologists.)
#	
#	12. Those who are most sensitive about "politically incorrect" terminology are not the average black ghetto-dweller, Asian immigrant, abused woman or disabled person, but a minority of activists, many of whom do not even belong to any "oppressed" group but come from privileged strata of society. Political correctness has its stronghold among university professors, who have secure employment with comfortable salaries, and the majority of whom are heterosexual white males from middle- to upper-middle-class families.
#	
#	13. Many leftists have an intense identification with the problems of groups that have an image of being weak (women), defeated (American Indians), repellent (homosexuals) or otherwise inferior. The leftists themselves feel that these groups are inferior. They would never admit to themselves that they have such feelings, but it is precisely because they do see these groups as inferior that they identify with their problems. (We do not mean to suggest that women, Indians, etc. ARE inferior; we are only making a point about leftist psychology.)
#	
#	14. Feminists are desperately anxious to prove that women are as strong and as capable as men. Clearly they are nagged by a fear that women may NOT be as strong and as capable as men.
#	
#	15. Leftists tend to hate anything that has an image of being strong, good and successful. They hate America, they hate Western civilization, they hate white males, they hate rationality. The reasons that leftists give for hating the West, etc. clearly do not correspond with their real motives. They SAY they hate the West because it is warlike, imperialistic, sexist, ethnocentric and so forth, but where these same faults appear in socialist countries or in primitive cultures, the leftist finds excuses for them, or at best he GRUDGINGLY admits that they exist; whereas he ENTHUSIASTICALLY points out (and often greatly exaggerates) these faults where they appear in Western civilization. Thus it is clear that these faults are not the leftist's real motive for hating America and the West. He hates America and the West because they are strong and successful.
#	
#	16. Words like "self-confidence," "self-reliance," "initiative," "enterprise," "optimism," etc., play little role in the liberal and leftist vocabulary. The leftist is anti-individualistic, pro-collectivist. He wants society to solve everyone's problems for them, satisfy everyone's needs for them, take care of them. He is not the sort of person who has an inner sense of confidence in his ability to solve his own problems and satisfy his own needs. The leftist is antagonistic to the concept of competition because, deep inside, he feels like a loser.
#	
#	17. Art forms that appeal to modern leftish intellectuals tend to focus on sordidness, defeat and despair, or else they take an orgiastic tone, throwing off rational control as if there were no hope of accomplishing anything through rational calculation and all that was left was to immerse oneself in the sensations of the moment.
#	
#	18. Modern leftish philosophers tend to dismiss reason, science, objective reality and to insist that everything is culturally relative. It is true that one can ask serious questions about the foundations of scientific knowledge and about how, if at all, the concept of objective reality can be defined. But it is obvious that modern leftish philosophers are not simply cool-headed logicians systematically analyzing the foundations of knowledge. They are deeply involved emotionally in their attack on truth and reality. They attack these concepts because of their own psychological needs. For one thing, their attack is an outlet for hostility, and, to the extent that it is successful, it satisfies the drive for power. More importantly, the leftist hates science and rationality because they classify certain beliefs as true (i.e., successful, superior) and other beliefs as false (i.e., failed, inferior). The leftist's feelings of inferiority run so deep that he cannot tolerate any classification of some things as successful or superior and other things as failed or inferior. This also underlies the rejection by many leftists of the concept of mental illness and of the utility of IQ tests. Leftists are antagonistic to genetic explanations of human abilities or behavior because such explanations tend to make some persons appear superior or inferior to others. Leftists prefer to give society the credit or blame for an individual's ability or lack of it. Thus if a person is "inferior" it is not his fault, but society's, because he has not been brought up properly.
#	
#	19. The leftist is not typically the kind of person whose feelings of inferiority make him a braggart, an egotist, a bully, a self-promoter, a ruthless competitor. This kind of person has not wholly lost faith in himself. He has a deficit in his sense of power and self-worth, but he can still conceive of himself as having the capacity to be strong, and his efforts to make himself strong produce his unpleasant behavior. [1] But the leftist is too far gone for that. Hisfeelings of inferiority are so ingrained that he cannot conceive of himself as individually strong and valuable. Hence the collectivism of the leftist. He can feel strong only as a member of a large organization or a mass movement with which he identifies himself.
#	
#	20. Notice the masochistic tendency of leftist tactics. Leftists protest by lying down in front of vehicles, they intentionally provoke police or racists to abuse them, etc. These tactics may often be effective, but many leftists use them not as a means to an end but because they PREFER masochistic tactics. Self-hatred is a leftist trait.
#	
#	21. Leftists may claim that their activism is motivated by compassion or by moral principles, and moral principle does play a role for the leftist of the oversocialized type. But compassion and moral principle cannot be the main motives for leftist activism. Hostility is too prominent a component of leftist behavior; so is the drive for power. Moreover, much leftist behavior is not rationally calculated to be of benefit to the people whom the leftists claim to be trying to help. For example, if one believes that affirmative action is good for black people, does it make sense to demand affirmative action in hostile or dogmatic terms? Obviously it would be more productive to take a diplomatic and conciliatory approach that would make at least verbal and symbolic concessions to white people who think that affirmative action discriminates against them. But leftist activists do not take such an approach because it would not satisfy their emotional needs. Helping black people is not their real goal. Instead, race problems serve as an excuse for them to express their own hostility and frustrated need for power. In doing so they actually harm black people, because the activists' hostile attitude toward the white majority tends to intensify race hatred.
#	
#	22. If our society had no social problems at all, the leftists would have to INVENT problems in order to provide themselves with an excuse for making a fuss.
#	
#	23. We emphasize that the foregoing does not pretend to be an accurate description of everyone who might be considered a leftist. It is only a rough indication of a general tendency of leftism.
#	
#	OVERSOCIALIZATION
#	
#	24. Psychologists use the term "socialization" to designate the process by which children are trained to think and act as society demands. A person is said to be well socialized if he believes in and obeys the moral code of his society and fits in well as a functioning part of that society. It may seem senseless to say that many leftists are oversocialized, since the leftist is perceived as a rebel. Nevertheless, the position can be defended. Many leftists are not such rebels as they seem.
#	
#	25. The moral code of our society is so demanding that no one can think, feel and act in a completely moral way. For example, we are not supposed to hate anyone, yet almost everyone hates somebody at some time or other, whether he admits it to himself or not. Some people are so highly socialized that the attempt to think, feel and act morally imposes a severe burden on them. In order to avoid feelings of guilt, they continually have to deceive themselves about their own motives and find moral explanations for feelings and actions that in reality have a non-moral origin. We use the term "oversocialized" to describe such people. [2]
#	
#	26. Oversocialization can lead to low self-esteem, a sense of powerlessness, defeatism, guilt, etc. One of the most important means by which our society socializes children is by making them feel ashamed of behavior or speech that is contrary to society's expectations. If this is overdone, or if a particular child is especially susceptible to such feelings, he ends by feeling ashamed of HIMSELF. Moreover the thought and the behavior of the oversocialized person are more restricted by society's expectations than are those of the lightly socialized person. The majority of people engage in a significant amount of naughty behavior. They lie, they commit petty thefts, they break traffic laws, they goofoff at work, they hate someone, they say spiteful things or they use some underhanded trick to get ahead of the other guy. The oversocialized person cannot do these things, or if he does do them he generates in himself a sense of shame and self-hatred. The oversocialized person cannot even experience, without guilt, thoughts or feelings that are contrary to the accepted morality; he cannot think "unclean" thoughts. And socialization is not just a matter of morality; we are socialized to conform to many norms of behavior that do not fall under the heading of morality. Thus the oversocialized person is kept on a psychological leash and spends his life running on rails that society has laid down for him. In many oversocialized people this results in a sense of constraint and powerlessness that can be a severe hardship. We suggest that oversocialization is among the more serious cruelties that human beings inflict on one another.
#	
#	27. We argue that a very important and influential segment of the modern left is oversocialized and that their oversocialization is of great importance in determining the direction of modern leftism. Leftists of the oversocialized type tend to be intellectuals or members of the upper-middle class. Notice that university intellectuals [3] constitute the most highly socialized segment of our society and also the most left-wing segment.
#	
#	28. The leftist of the oversocialized type tries to get off his psychological leash and assert his autonomy by rebelling. But usually he is not strong enough to rebel against the most basic values of society. Generally speaking, the goals of today's leftists are NOT in conflict with the accepted morality. On the contrary, the left takes an accepted moral principle, adopts it as its own, and then accuses mainstream society of violating that principle. Examples: racial equality, equality of the sexes, helping poor people, peace as opposed to war, nonviolence generally, freedom of expression, kindness to animals. More fundamentally, the duty of the individual to serve society and the duty of society to take care of the individual. All these have been deeply rooted values of our society (or at least of its middle and upper classes [4] for a long time. These values are explicitly or implicitly expressed or presupposed in most of the material presented to us by the mainstream communications media and the educational system. Leftists, especially those of the oversocialized type, usually do not rebel against these principles but justify their hostility to society by claiming (with some degree of truth) that society is not living up to these principles.
#	
#	29. Here is an illustration of the way in which the oversocialized leftist shows his real attachment to the conventional attitudes of our society while pretending to be in rebellion against it. Many leftists push for affirmative action, for moving black people into high-prestige jobs, for improved education in black schools and more money for such schools; the way of life of the black "underclass" they regard as a social disgrace. They want to integrate the black man into the system, make him a business executive, a lawyer, a scientist just like upper-middle-class white people. The leftists will reply that the last thing they want is to make the black man into a copy of the white man; instead, they want to preserve African American culture. But in what does this preservation of African American culture consist? It can hardly consist in anything more than eating black-style food, listening to black-style music, wearing black-style clothing and going to a black-style church or mosque. In other words, it can express itself only in superficial matters. In all ESSENTIAL respects most leftists of the oversocialized type want to make the black man conform to white, middle-class ideals. They want to make him study technical subjects, become an executive or a scientist, spend his life climbing the status ladder to prove that black people are as good as white. They want to make black fathers "responsible," they want black gangs to become nonviolent, etc. But these are exactly the values of the industrial-technological system. The system couldn't care less what kind of music a man listens to, what kind of clothes he wears or what religion he believes in as long as he studies in school, holds a respectable job, climbs the status ladder, is a "responsible" parent, is nonviolent and so forth. In effect, however much he may deny it, the oversocialized leftist wants to integrate the black man into the system and make him adopt its values.
#	
#	30. We certainly do not claim that leftists, even of the oversocialized type, NEVER rebel against the fundamental values of our society. Clearly they sometimes do. Some oversocialized leftists have gone so far as to rebel against one of modern society's most important principles by engaging in physical violence. By their own account, violence is for them a form of "liberation." In other words, by committing violence they break through the psychological restraints that have been trained into them. Because they are oversocialized these restraints have been more confining for them than for others; hence their need to break free of them. But they usually justify their rebellion in terms of mainstream values. If they engage in violence they claim to be fighting against racism or the like.
#	
#	31. We realize that many objections could be raised to the foregoing thumbnail sketch of leftist psychology. The real situation is complex, and anything like a complete description of it would take several volumes even if the necessary data were available. We claim only to have indicated very roughly the two most important tendencies in the psychology of modern leftism.
#	
#	32. The problems of the leftist are indicative of the problems of our society as a whole. Low self-esteem, depressive tendencies and defeatism are not restricted to the left. Though they are especially noticeable in the left, they are widespread in our society. And today's society tries to socialize us to a greater extent than any previous society. We are even told by experts how to eat, how to exercise, how to make love, how to raise our kids and so forth.
#	
#	THE POWER PROCESS
#	
#	33. Human beings have a need (probably based in biology) for something that we will call the "power process." This is closely related to the need for power (which is widely recognized) but is not quite the same thing. The power process has four elements. The three most clear-cut of these we call goal, effort and attainment of goal. (Everyone needs to have goals whose attainment requires effort, and needs to succeed in attaining at least some of his goals.) The fourth element is more difficult to define and may not be necessary for everyone. We call it autonomy and will discuss it later (paragraphs 42-44).
#	
#	34. Consider the hypothetical case of a man who can have anything he wants just by wishing for it. Such a man has power, but he will develop serious psychological problems. At first he will have a lot of fun, but by and by he will become acutely bored and demoralized. Eventually he may become clinically depressed. History shows that leisured aristocracies tend to become decadent. This is not true of fighting aristocracies that have to struggle to maintain their power. But leisured, secure aristocracies that have no need to exert themselves usually become bored, hedonistic and demoralized, even though they have power. This shows that power is not enough. One must have goals toward which to exercise one's power.
#	
#	35. Everyone has goals; if nothing else, to obtain the physical necessities of life: food, water and whatever clothing and shelter are made necessary by the climate. But the leisured aristocrat obtains these things without effort. Hence his boredom and demoralization.
#	
#	36. Nonattainment of important goals results in death if the goals are physical necessities, and in frustration if nonattainment of the goals is compatible with survival. Consistent failure to attain goals throughout life results in defeatism, low self-esteem or depression.
#	
#	37, Thus, in order to avoid serious psychological problems, a human being needs goals whose attainment requires effort, and he must have a reasonable rate of success in attaining his goals.
#	
#	SURROGATE ACTIVITIES
#	
#	38. But not every leisured aristocrat becomes bored and demoralized. For example, the emperor Hirohito, instead of sinking into decadent hedonism, devoted himself to marine biology, a field in which he became distinguished. When people do not have to exert themselves to satisfy their physical needs they often set up artificial goals for themselves. In many cases they then pursue these goals with the same energy and emotional involvement that they otherwise would have put into the search for physical necessities. Thus the aristocrats of the Roman Empire had their literary pretensions; many European aristocrats a few centuries ago invested tremendous time and energy in hunting, though they certainly didn't need the meat; other aristocracies have competed for status through elaborate displays of wealth; and a few aristocrats, like Hirohito, have turned to science.
#	
#	39. We use the term "surrogate activity" to designate an activity that is directed toward an artificial goal that people set up for themselves merely in order to have some goal to work toward, or let us say, merely for the sake of the "fulfillment" that they get from pursuing the goal. Here is a rule of thumb for the identification of surrogate activities. Given a person who devotes much time and energy to the pursuit of goal X, ask yourself this: If he had to devote most of his time and energy to satisfying his biological needs, and if that effort required him to use his physical and mental faculties in a varied and interesting way, would he feel seriously deprived because he did not attain goal X? If the answer is no, then the person's pursuit of goal X is a surrogate activity. Hirohito's studies in marine biology clearly constituted a surrogate activity, since it is pretty certain that if Hirohito had had to spend his time working at interesting non-scientific tasks in order to obtain the necessities of life, he would not have felt deprived because he didn't know all about the anatomy and life-cycles of marine animals. On the other hand the pursuit of sex and love (for example) is not a surrogate activity, because most people, even if their existence were otherwise satisfactory, would feel deprived if they passed their lives without ever having a relationship with a member of the opposite sex. (But pursuit of an excessive amount of sex, more than one really needs, can be a surrogate activity.)
#	
#	40. In modern industrial society only minimal effort is necessary to satisfy one's physical needs. It is enough to go through a training program to acquire some petty technical skill, then come to work on time and exert the very modest effort needed to hold a job. The only requirements are a moderate amount of intelligence and, most of all, simple OBEDIENCE. If one has those, society takes care of one from cradle to grave. (Yes, there is an underclass that cannot take the physical necessities for granted, but we are speaking here of mainstream society.) Thus it is not surprising that modern society is full of surrogate activities. These include scientific work, athletic achievement, humanitarian work, artistic and literary creation, climbing the corporate ladder, acquisition of money and material goods far beyond the point at which they cease to give any additional physical satisfaction, and social activism when it addresses issues that are not important for the activist personally, as in the case of white activists who work for the rights of nonwhite minorities. These are not always PURE surrogate activities, since for many people they may be motivated in part by needs other than the need to have some goal to pursue. Scientific work may be motivated in part by a drive for prestige, artistic creation by a need to express feelings, militant social activism by hostility. But for most people who pursue them, these activities are in large part surrogate activities. For example, the majority of scientists will probably agree that the "fulfillment" they get from their work is more important than the money and prestige they earn.
#	
#	41. For many if not most people, surrogate activities are less satisfying than the pursuit of real goals (that is, goals that people would want to attain even if their need for the power process were already fulfilled). One indication of this is the fact that, in many or most cases, people who are deeply involved in surrogate activities are never satisfied, never at rest. Thus the money-maker constantly strives for more and more wealth. The scientist no sooner solves one problem than he moves on to the next. The long-distance runner drives himself to run always farther and faster. Many people who pursue surrogate activities will say that they get far more fulfillment from these activities than they do from the "mundane" business of satisfying their biological needs, but that is because in our society the effort needed to satisfy the biological needs has been reduced to triviality. More importantly, in our society people do not satisfy their biological needs AUTONOMOUSLY but by functioning as parts of an immense social machine. In contrast, people generally have a great deal of autonomy in pursuing their surrogate activities.
#	
#	AUTONOMY
#	
#	42. Autonomy as a part of the power process may not be necessary for every individual. But most people need a greater or lesser degree of autonomy in working toward their goals. Their efforts must be undertaken on their own initiative and must be under their own direction and control. Yet most people do not have to exert this initiative, direction and control as single individuals. It is usually enough to act as a member of a SMALL group. Thus if half a dozen people discuss a goal among themselves and make a successful joint effort to attain that goal, their need for the power process will be served. But if they work under rigid orders handed down from above that leave them no room for autonomous decision and initiative, then their need for the power process will not be served. The same is true when decisions are made on a collective basis if the group making the collective decision is so large that the role of each individual is insignificant. [5]
#	
#	43. It is true that some individuals seem to have little need for autonomy. Either their drive for power is weak or they satisfy it by identifying themselves with some powerful organization to which they belong. And then there are unthinking, animal types who seem to be satisfied with a purely physical sense of power (the good combat soldier, who gets his sense of power by developing fighting skills that he is quite content to use in blind obedience to his superiors).
#	
#	44. But for most people it is through the power processshaving a goal, making an AUTONOMOUS effort and attaining the goalsthat self-esteem, self-confidence and a sense of power are acquired. When one does not have adequate opportunity to go through the power process the consequences are (depending on the individual and on the way the power process is disrupted) boredom, demoralization, low self-esteem, inferiority feelings, defeatism, depression, anxiety, guilt, frustration, hostility, spouse or child abuse, insatiable hedonism, abnormal sexual behavior, sleep disorders, eating disorders, etc. [6]
#	
#	SOURCES OF SOCIAL PROBLEMS
#	
#	45. Any of the foregoing symptoms can occur in any society, but in modern industrial society they are present on a massive scale. We aren't the first to mention that the world today seems to be going crazy. This sort of thing is not normal for human societies. There is good reason to believe that primitive man suffered from less stress and frustration and was better satisfied with his way of life than modern man is. It is true that not all was sweetness and light in primitive societies. Abuse of women was common among the Australian aborigines, transexuality was fairly common among some of the American Indian tribes. But it does appear that GENERALLY SPEAKING the kinds of problems that we have listed in the preceding paragraph were far less common among primitive peoples than they are in modern society.
#	
#	46. We attribute the social and psychological problems of modern society to the fact that that society requires people to live under conditions radically different from those under which the human race evolved and to behave in ways that conflict with the patterns of behavior that the human race developed while living under the earlier conditions. It is clear from what we have already written that we consider lack of opportunity to properly experience the power process as the most important of the abnormal conditions to which modern society subjects people. But it is not the only one. Before dealing with disruption of the power process as a source of social problems we will discuss some of the other sources.
#	
#	47. Among the abnormal conditions present in modern industrial society are excessive density of population, isolation of man from nature, excessive rapidity of social change and the breakdown of natural small-scale communities such as the extended family, the village or the tribe.
#	
#	48. It is well known that crowding increases stress and aggression. The degree of crowding that exists today and the isolation of man from nature are consequences of technological progress. All pre-industrial societies were predominantly rural. The Industrial Revolution vastly increased the size of cities and the proportion of the population that lives in them, and modern agricultural technology has made it possible for the Earth to support a far denser population than it ever did before. (Also, technology exacerbates the effects of crowding because it puts increased disruptive powers in people's hands. For example, a variety of noise-making devices: power mowers, radios, motorcycles, etc. If the use of these devices is unrestricted, people who want peace and quiet are frustrated by the noise. If their use is restricted, people who use the devices are frustrated by the regulations. But if these machines had never been invented there would have been no conflict and no frustration generated by them.)
#	
#	49. For primitive societies the natural world (which usually changes only slowly) provided a stable framework and therefore a sense of security. In the modern world it is human society that dominates nature rather than the other way around, and modern society changes very rapidly owing to technological change. Thus there is no stable framework.
#	
#	50. The conservatives are fools: They whine about the decay of traditional values, yet they enthusiastically support technological progress and economic growth. Apparently it never occurs to them that you can't make rapid, drastic changes in the technology and the economy of a society without causing rapid changes in all other aspects of the society as well, and that such rapid changes inevitably break down traditional values.
#	
#	51. The breakdown of traditional values to some extent implies the breakdown of the bonds that hold together traditional small-scale social groups. The disintegration of small-scale social groups is also promoted by the fact that modern conditions often require or tempt individuals to move to new locations, separating themselves from their communities. Beyond that, a technological society HAS TO weaken family ties and local communities if it is to function efficiently. In modern society an individual's loyalty must be first to the system and only secondarily to a small-scale community, because if the internal loyalties of small-scale communities were stronger than loyalty to the system, such communities would pursue their own advantage at the expense of the system.
#	
#	52. Suppose that a public official or a corporation executive appoints his cousin, his friend or his co-religionist to a position rather than appointing the person best qualified for the job. He has permitted personal loyalty to supersede his loyalty to the system, and that is "nepotism" or "discrimination," both of which are terrible sins in modern society. Would-be industrial societies that have done a poor job of subordinating personal or local loyalties to loyalty to the system are usually very inefficient. (Look at Latin America.) Thus an advanced industrial society can tolerate only those small-scale communities that are emasculated, tamed and made into tools of the system. [7]
#	
#	53. Crowding, rapid change and the breakdown of communities have been widely recognized as sources of social problems. But we do not believe they are enough to account for the extent of the problems that are seen today.
#	
#	54. A few pre-industrial cities were very large and crowded, yet their inhabitants do not seem to have suffered from psychological problems to the same extent as modern man. In America today there still are uncrowded rural areas, and we find there the same problems as in urban areas, though the problems tend to be less acute in the rural areas. Thus crowding does not seem to be the decisive factor.
#	
#	55. On the growing edge of the American frontier during the 19th century, the mobility of the population probably broke down extended families and small-scale social groups to at least the same extent as these are broken down today. In fact, many nuclear families lived by choice in such isolation, having no neighbors within several miles, that they belonged to no community at all, yet they do not seem to have developed problems as a result.
#	
#	56. Furthermore, change in American frontier society was very rapid and deep. A man might be born and raised in a log cabin, outside the reach of law and order and fed largely on wild meat; and by the time he arrived at old age he might be working at a regular job and living in an ordered community with effective law enforcement. This was a deeper change than that which typically occurs in the life of a modern individual, yet it does not seem to have led to psychological problems. In fact, 19th century American society had an optimistic and self-confident tone, quite unlike that of today's society. [8]
#	
#	57. The difference, we argue, is that modern man has the sense (largely justified) that change is IMPOSED on him, whereas the 19th century frontiersman had the sense (also largely justified) that he created change himself, by his own choice. Thus a pioneer settled on a piece of land of his own choosing and made it into a farm through his own effort. In those days an entire county might have only a couple of hundred inhabitants and was a far more isolated and autonomous entity than a modern county is. Hence the pioneer farmer participated as a member of a relatively small group in the creation of a new, ordered community. One may well question whether the creation of this community was an improvement, but at any rate it satisfied the pioneer's need for the power process.
#	
#	58. It would be possible to give other examples of societies in which there has been rapid change and/or lack of close community ties without the kind of massive behavioral aberration that is seen in today's industrial society. We contend that the most important cause of social and psychological problems in modern society is the fact that people have insufficient opportunity to go through the power process in a normal way. We don't mean to say that modern society is the only one in which the power process has been disrupted. Probably most if not all civilized societies have interfered with the power process to a greater or lesser extent. But in modern industrial society the problem has become particularly acute. Leftism, at least in its recent (mid- to late-20th century) form, is in part a symptom of deprivation with respect to the power process. 