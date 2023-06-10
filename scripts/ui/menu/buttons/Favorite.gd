extends Button

func _pressed():
	if SSP.single_map_mode or !SSP.selected_song: return
	if SSP.favorite_songs.has(SSP.selected_song.id):
		SSP.remove_favorite(SSP.selected_song.id)
	else: SSP.add_favorite(SSP.selected_song.id)

func upd(_s=null):
	if (!SSP.single_map_mode) and SSP.selected_song != null:
		disabled = false
		if SSP.is_favorite(SSP.selected_song.id):
			text = "Favorited!"
			pressed = true
		else:
			text = "Favorite"
			pressed = false
	else:
		disabled = true

func _ready():
	SSP.connect("selected_song_changed",self,"upd")
	SSP.connect("favorite_songs_changed",self,"upd")
	upd()
