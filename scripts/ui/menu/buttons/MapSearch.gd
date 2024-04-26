extends LineEdit

func update_txt(_v=null):
	get_parent().get_parent().get_node("S/VBoxContainer").update_search_text(text)
	Rhythia.last_search_str = text

func _ready():
	connect("text_changed",self,"update_txt")
	text = Rhythia.last_search_str
	update_txt()

func _input(event): # any unicode input starts search
	if event is InputEventKey and event.is_pressed():
		#if space return so you can use space to play map
		if event.scancode == KEY_SPACE: return
		var unicode = event.get_unicode()
		if unicode != 0:
			grab_focus()
			
