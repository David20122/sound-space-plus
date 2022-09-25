extends ColorRect

var song:Song = SSP.registry_song.get_item("divetek_cascada_-_everytime_we_touch_fvrwvrd_remix")
var dance:SimpleDanceMover

var ms:float = 0
var active:bool = false

var last_usec = OS.get_ticks_usec()

func _process(delta:float):
	var u = OS.get_ticks_usec()
	delta = float(u - last_usec) / 1_000_000.0
	last_usec = OS.get_ticks_usec()
	if active:
		ms += delta*1000
		$Main/Control/Cursor.position = (Vector2(100,100) * dance.update(ms)) - Vector2(100,100)
		$Label.text = """
		pos: %s
		
		t: %s
		r: %s
		tme: %s
		
		p1: %s
		p2: %s
		last: %s

		Start: %s
		End: %s

		StartPos: %s
		StartTime: %s
		EndPos: %s
		EndTime: %s
		Duration: %s

		StartX: %s
		StartY: %s
		EndX: %s
		EndY: %s
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
		
		var playback_pos:float = $AudioStreamPlayer.get_playback_position()*1000.0
		if abs(playback_pos - (ms + SSP.music_offset)) > 65:
			if SSP.desync_alerts:
				Globals.notify(
					Globals.NOTIFY_WARN,
					"Audio was desynced by %.2f ms, correcting." % [playback_pos - (ms + SSP.music_offset)],
					"Music Sync Correction"
				)
			$AudioStreamPlayer.play((ms + SSP.music_offset)/1000.0)
		$Time.value = ms

func _ready():
	$AudioStreamPlayer.stream = song.stream()
	$Time.max_value = song.last_ms
	yield($Button,"pressed")
	$Main.setup(song)
	dance = SimpleDanceMover.new(song)
	active = true
	$Main.active = true
	$AudioStreamPlayer.play(SSP.music_offset/1000.0)
