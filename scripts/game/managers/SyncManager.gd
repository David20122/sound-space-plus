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
var start_time:int = 0
var current_time:float = 0

func start(from:float=0):
	start_time = Time.get_ticks_usec()
	start_offset = from
	playing = true

func finish():
	playing = false
	finished.emit()

func _start_audio():
	if audio_stream is AudioStreamMP3:
		(audio_stream as AudioStreamMP3).loop = false
	if audio_stream is AudioStreamWAV:
		(audio_stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_DISABLED
	audio_player.stream = audio_stream
	audio_player.pitch_scale = playback_speed
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	audio_player.play(current_time)

func _process(delta):
	if !playing: return
	var time = playback_speed * (Time.get_ticks_usec() - start_time) / 1000000.0
	time -= time_delay
	time += start_offset
	if time > audio_stream.get_length():
		finish()
		return
	if time >= 0 and !audio_player.playing:
		_start_audio()
	current_time = time
