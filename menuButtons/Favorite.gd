extends Button

var has_auto_previewed:bool = false

func _pressed():
	if !SSP.selected_song: return
	if SSP.favorite_songs.has(SSP.selected_song.id):
		SSP.remove_favorite(SSP.selected_song.id)
	else: SSP.add_favorite(SSP.selected_song.id)

func upd(_s=null):
	if SSP.selected_song:
		disabled = false
		if SSP.is_favorite(SSP.selected_song.id):
			text = "Favorited!"
			pressed = true
		else:
			text = "Favorite"
			pressed = false
	else: disabled = true

func _ready():
	SSP.connect("selected_song_changed",self,"upd")
	SSP.connect("favorite_songs_changed",self,"upd")
	upd(SSP.selected_song)
