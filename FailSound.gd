extends AudioStreamPlayer

func _ready():
	if SSP.just_ended_song and SSP.song_end_type != Globals.END_PASS: play()
