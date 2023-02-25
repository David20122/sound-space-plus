extends HUDItem
class_name TimerHUD

var sync_manager:SyncManager
var song_name:String

func _process(_delta):
	if !sync_manager: return
	$Song.text = song_name
	var current_time = maxf(sync_manager.current_time,0)
	var length = sync_manager.audio_stream.get_length()
	$Timer.text = "%s:%02d / %s:%02d" % [
		floori(current_time/60),
		floori(int(current_time)%60),
		floori(length/60),
		floori(int(length)%60)
	]
	$Progress.value = current_time / length
