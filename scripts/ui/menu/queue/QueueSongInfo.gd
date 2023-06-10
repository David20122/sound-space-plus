extends Control

func comma_sep(number):
	var string = str(number)
	var mod = string.length() % 3
	var res = ""
	
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]
	
	return res

func hide_info(_s=null):
	visible = false

func get_time_ms(ms:float):
	var s = max(floor(ms / 1000),0)
	var m = floor(s / 60)
	var rs = fmod(s,60)
	return "%d:%02d" % [m,rs]

var rainbow_letter_grade:bool = false
func update_letter_grade(acc:float=0):
	var grade:String = "--"
	var gcol:Color = Color(1,0,1)
	var shine:float = 0
	rainbow_letter_grade = (acc == 1)
	if acc == 1:
		grade = "SS"
		gcol = Color.from_hsv(SSP.rainbow_t*0.1,0.5,1)
	elif acc >= 0.98:
		grade = "S"
		gcol = Color("#91fffa")
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
	
	$LetterGrade.text = grade
	$LetterGrade.material.set_shader_param("shine",shine)
	$LetterGrade.set("custom_colors/font_color",gcol)

func _process(delta):
	if rainbow_letter_grade:
		$LetterGrade.set("custom_colors/font_color",Color.from_hsv(SSP.rainbow_t*0.1,0.4,1))

func _ready():
	$NewBest.stream = SSP.pb_snd
	if $NewBest.stream != SSP.normal_pb_sound:
		$NewBest.pitch_scale = 1
	
	var is_best:bool = SSP.do_pb_check_and_set()
	if is_best: $NewBest.play()
	if SSP.song_end_type == Globals.END_PASS:
		if SSP.was_replay: $Result.text = "Replay passed"
		elif is_best: $Result.text = "New best!"
		else: $Result.text = "You passed!"
		$Result.set("custom_colors/font_color",Color("#6ff1ff"))
	elif SSP.was_replay: $Result.text = "Replay failed"
	elif is_best:
		$Result.text = "You failed (new best!)"
		$Result.set("custom_colors/font_color",Color("#ea4aca"))
	else: $Result.text = "You failed!"
	
	
	$FullCombo.visible = SSP.song_end_misses == 0 && SSP.song_end_type == Globals.END_PASS
	$Misses.visible = !SSP.song_end_misses == 0 || !SSP.song_end_type == Globals.END_PASS
	$Misses.text = comma_sep(SSP.song_end_misses)
	
	$NoPauses.visible = SSP.song_end_pause_count == 0
	$Pauses.visible = !SSP.song_end_pause_count == 0
	$Pauses.text = comma_sep(SSP.song_end_pause_count)

	$Accuracy.text = "%s/%s\n%.03f%%" % [
		comma_sep(SSP.song_end_hits),
		comma_sep(SSP.song_end_total_notes),
		(float(SSP.song_end_hits)/float(SSP.song_end_total_notes))*100
	]
	update_letter_grade(float(SSP.song_end_hits)/float(SSP.song_end_total_notes))
	$Progress.text = "%s\n%.1f%%" % [SSP.song_end_time_str,clamp(SSP.song_end_position/SSP.song_end_length,0,1)*100]
	
	SSP.just_ended_song = false
