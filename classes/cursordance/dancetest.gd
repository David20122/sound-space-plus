extends Control

var song:Song = SSP.selected_song
var dance:DanceMover

var ms:float = -1000
var active:bool = false

var last_usec = OS.get_ticks_usec()

func comma_sep(number:float) -> String:
	var string = str(number)
	var mod = string.length() % 3
	var res = ""
	
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]
	
	return res

func get_time_ms(ms:float) -> String:
	var s = max(floor(ms / 1000),0)
	var m = floor(s / 60)
	var rs = fmod(s,60)
	return "%d:%02d" % [m,rs]

func update_cursor():
	$Main/Control/Cursor.position = (Vector2(100,100) * dance.update(ms)) - Vector2(100,100)
	$Label.text = """
	pos: %s\n\nt: %s\nr: %s\ntme: %s\n\np1: %s\np2: %s\nlast: %s\n
	Start: %s\nEnd: %s\n\nStartPos: %s\nStartTime: %s\nEndPos: %s\nEndTime: %s\nDuration: %s\n
	StartX: %s\nStartY: %s\nEndX: %s\nEndY: %s\n
	""" % [
		$Main/Control/Cursor.position,
		dance.t, dance.r, dance.tme,
		dance.p1, dance.p2, dance.last,
		dance.Start, dance.End,
		dance.StartPos, dance.StartTime,
		dance.EndPos, dance.EndTime,
		dance.Duration,
		dance.StartX, dance.StartY,
		dance.EndX, dance.EndY
	]

func _process(delta:float):
	var u = OS.get_ticks_usec()
	delta = float(u - last_usec) / 1_000_000.0
	last_usec = OS.get_ticks_usec()
	if active:
		ms += delta*1000.0*Globals.speed_multi[SSP.mod_speed_level]
		update_cursor()
		
		var playback_pos:float = $Main/Music.get_playback_position()*1000.0
		
		if (!$Main/Music.playing and (ms + SSP.music_offset) >= 0
		and ((ms + SSP.music_offset)/1000 < $Main/Music.stream.get_length())):
			$Main/Music.play((ms + SSP.music_offset)/1000.0)
			
		if $Main/Music.playing and ((ms + SSP.music_offset) < $Main/Music.stream.get_length() and
		ms < song.last_ms and abs(playback_pos - (ms + SSP.music_offset)) > 85):
			$Main/Music.play((ms + SSP.music_offset)/1000.0)
			$Main.flash_time = 0.5
			if SSP.desync_alerts:
				Globals.notify(
					Globals.NOTIFY_WARN,
					"Audio was desynced by %.2f ms, correcting." % [playback_pos - (ms + SSP.music_offset)],
					"Music Sync Correction"
				)
		
		
		$Time.value = ms
		$Buttons/Current/M/L.text = "%s / %s (%s / %s)" % [
			get_time_ms(ms), get_time_ms(song.last_ms),
			comma_sep(floor(ms)), comma_sep(floor(song.last_ms))
		]

func set_playing(v:bool):
	active = v
	$Time.editable = !v
	$Buttons/StartStop/H/Start.disabled = v
	$Buttons/StartStop/H/Stop.disabled = !v
	if v and (ms + SSP.music_offset) >= 0: $Main/Music.play((ms + SSP.music_offset)/1000.0)
	else: $Main/Music.stop()

func seek(to:float):
	if active: set_playing(true)
	ms = to
	update_cursor()
	$Buttons/Current/M/L.text = "%s / %s (%s / %s)" % [
		get_time_ms(ms), get_time_ms(song.last_ms),
		comma_sep(floor(ms)), comma_sep(floor(song.last_ms))
	]
#	if was_playing: set_playing(true)

func timebar_seek(to:float):
	if !active: seek(to)

func direct_seek():
	if $Buttons/Seek/H/LineEdit.text.is_valid_float():
		seek($Buttons/Seek/H/LineEdit.text.to_float())

func _ready():
	$Main/Music.pitch_scale = Globals.speed_multi[SSP.mod_speed_level]
	$Main/Music.stream = song.stream()
	$Main/Music.stream.loop = false
	$Time.max_value = song.last_ms
	$Main.setup(song)
	
	$Main.active = true
	dance = DirectionalDanceMover.new(song)
	update_cursor()
	
	yield($Buttons/StartStop/H/Start,"pressed")
	$Buttons/StartStop/H/Start.disabled = true
	$Buttons/StartStop/H/Stop.disabled = false
	active = true
	
	$Buttons/StartStop/H/Start.connect("pressed",self,"set_playing",[true])
	$Buttons/StartStop/H/Stop.connect("pressed",self,"set_playing",[true])
	$Buttons/Seek/H/Seek.connect("pressed",self,"direct_seek")
	$Time.connect("value_changed",self,"timebar_seek")
