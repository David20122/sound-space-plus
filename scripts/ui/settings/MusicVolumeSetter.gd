extends AudioStreamPlayer

var target_volume_db = Rhythia.music_volume_db

func _process(delta):
	if volume_db != target_volume_db:
		volume_db = min(volume_db + ((target_volume_db+55)*delta*6),target_volume_db)

func upd(): target_volume_db = Rhythia.music_volume_db

func _ready():
	Rhythia.connect("volume_changed",self,"upd")
	upd()
	volume_db = target_volume_db
