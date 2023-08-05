extends OptionButton

var sd = false

func item_selected(idx:int):
	if !sd:
		var res = Rhythia.selected_song.change_difficulty(idx - 1)
		if res == OK:
			disabled = true
			text = "Updated difficulty!"
			Rhythia.emit_signal("favorite_songs_changed") # Force a map list reload
			yield(get_tree().create_timer(0.75),"timeout")
			text = "Change Difficulty"
			disabled = false
		else:
			disabled = true
			text = "Failed"
			yield(get_tree().create_timer(0.75),"timeout")
			text = "Change Difficulty"
			disabled = false

func upd(_s=null):
	sd = true
	select(Rhythia.selected_song.difficulty + 1)
	sd = false
	text = "Change Difficulty"

#func _pressed():
#	set_item_text(0,"None")

func _ready():
	Rhythia.connect("selected_song_changed",self,"upd")
	add_item("N/A",0)
	add_item("Easy",1)
	add_item("Medium",2)
	add_item("Hard",3)
	add_item("Logic?",4)
	add_item("助",5)
	connect("item_selected",self,"item_selected")
	text = "Change Difficulty"
