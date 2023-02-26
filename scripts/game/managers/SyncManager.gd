extends BaseManager
class_name SyncManager

signal finished

@export_node_path("AudioStreamPlayer") var audio_player_path
@onready var audio_player:AudioStreamPlayer = get_node(audio_player_path)

var audio_stream:AudioStream

var playing:bool = false
var playback_speed:float = 1

var time_delay:float = 0
var start_offset:float = 0
var last_time:int = 0

var real_time:float = 0
var current_time:float = 0

func start(from:float=0):
	last_time = Time.get_ticks_usec()
	start_offset = from
	real_time = start_offset
	playing = true

func finish():
	playing = false
	finished.emit()

func _start_audio():
	if audio_stream is AudioStreamMP3:
		(audio_stream as AudioStreamMP3).loop = false
	if audio_stream is AudioStreamWAV:
		(audio_stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_DISABLED
	if audio_stream is AudioStreamOggVorbis:
		(audio_stream as AudioStreamOggVorbis).loop = false
	audio_player.stream = audio_stream
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	audio_player.play(real_time)

var paused:bool = false
func _notification(what):
	if what == Node.NOTIFICATION_PAUSED:
		paused = true
		audio_player.stop()

func _process(delta):
	if !playing: return
	var now = Time.get_ticks_usec()
	if paused:
		paused = false
		last_time = now + 0.1
	var time = playback_speed * (now - last_time) / 1000000.0
	last_time = now
#	time -= time_delay
#	time += start_offset
	real_time += time
	current_time = real_time - time_delay
	if current_time > audio_stream.get_length():
		finish()
		return
	if real_time >= 0 and !audio_player.playing and playback_speed > 0:
		_start_audio()
	if playback_speed > 0:
		audio_player.pitch_scale = playback_speed
	elif audio_player.playing:
		audio_player.stop()
