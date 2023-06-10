extends LineEdit

func update_txt(_v=null):
	get_parent().get_parent().get_node("S/G").update_search_text(text)
	SSP.last_search_str = text

func _ready():
	connect("text_changed",self,"update_txt")
	text = SSP.last_search_str
	update_txt()
