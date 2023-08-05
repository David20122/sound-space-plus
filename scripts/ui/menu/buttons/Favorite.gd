extends Button

func _pressed():
	if Rhythia.single_map_mode or !Rhythia.selected_song: return
	if Rhythia.favorite_songs.has(Rhythia.selected_song.id):
		Rhythia.remove_favorite(Rhythia.selected_song.id)
	else: Rhythia.add_favorite(Rhythia.selected_song.id)

func upd(_s=null):
	if (!Rhythia.single_map_mode) and Rhythia.selected_song != null:
		disabled = false
		if Rhythia.is_favorite(Rhythia.selected_song.id):
			text = "Favorited!"
			pressed = true
		else:
			text = "Favorite"
			pressed = false
	else:
		disabled = true

func _ready():
	Rhythia.connect("selected_song_changed",self,"upd")
	Rhythia.connect("favorite_songs_changed",self,"upd")
	upd()
