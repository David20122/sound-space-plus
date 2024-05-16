extends LineEdit

func update_txt(_v=null):
	get_parent().get_parent().get_node("S/VBoxContainer").update_author_search_text(text)
	Rhythia.last_author_search_str = text

func _ready():
	connect("text_changed",self,"update_txt")
	text = Rhythia.last_author_search_str
	update_txt()
	get_parent().get_parent().get_node("S/VBoxContainer").connect("reset_filters",self,"_on_reset_filters")
	get_parent().get_parent().get_node("S/VBoxContainer").connect("lock_type",self,"_on_lock_type")
	get_parent().get_parent().get_parent().get_node("Results/Results/RS/H1/Info/Run").connect("lock_type",self,"_on_lock_type")


func _on_reset_filters():
	print("resetting author search")
	text = ""
	update_txt()

func _on_lock_type():
	#prevent input
	set_editable(false)
