extends Node

var leaving:bool = false

var black_fade_target:bool = false
var black_fade:float = 0

var prev_song = SSP.selected_song
var next_song

func leave():
	leaving = true
	black_fade_target = true

func _ready():
	get_tree().paused = false
	
	$BlackFade.visible = true
	black_fade = 1
	$BlackFade.color = Color(0,0,0,black_fade)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	$Music.volume_db = -12 - (40*black_fade)
	next_song = SSP.get_next()
	$C/V/H/Queue/EndInfo.upd()
	if next_song:
		$C/V/Next/H/V/Next.text = "Next: %s" % [next_song.name] 
		$Music.stream = next_song.stream()
		$Music.play($Music.stream.get_length() * 0.3)
	else:
		$C/V/Next/H/V/Next.text = "End of queue - returning to menu"
		if SSP.song_end_type == Globals.END_FAIL:
			$C/V/Next/H/V/Next.text = "Failed - returning to menu"
		elif SSP.song_end_type == Globals.END_GIVEUP:
			$C/V/Next/H/V/Next.text = "Gave up - returning to menu"

var result
var left:bool = false
var ending:bool = false

var t = 0

func _process(delta):
	$Music.volume_db = -12 - (40*black_fade)
	if black_fade_target && black_fade != 1:
		black_fade = min(black_fade + (delta/0.3),1)
		$BlackFade.color = Color(0,0,0,black_fade)
	elif !black_fade_target && black_fade != 0:
		black_fade = max(black_fade - (delta/0.3),0)
		$BlackFade.color = Color(0,0,0,black_fade)
	
	t += delta
	$C/V/Next/H/ProgressBar.value = t
	$C/V/Next/H/V/Time.text = String(max(ceil(10.0 - t),0))
	
	if t >= 10:
		leaving = true
		black_fade = true
	if leaving and black_fade == 1:
		if SSP.queue_active:
			SSP.select_song(next_song)
			get_tree().change_scene("res://songload.tscn")
		else:
			get_tree().change_scene("res://menuload.tscn")
