extends OptionButton

var difficulty:int = Globals.DIFF_UNKNOWN

func item_selected(idx:int):
	print(idx)
	difficulty = idx - 1

#func _pressed():
#	set_item_text(0,"None")

func _ready():
	add_item("Difficulty (N/A)",0)
	add_item("Easy",1)
	add_item("Medium",2)
	add_item("Hard",3)
	add_item("Logic?",4)
	add_item("助",5)
	connect("item_selected",self,"item_selected")
