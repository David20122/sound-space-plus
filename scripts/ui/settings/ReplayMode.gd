extends OptionButton

func upd(value):
	Rhythia.record_mode = get_item_id(value)

func _process(_d):
	if get_item_id(selected) != Rhythia.record_mode: upd(selected)
	
func _ready():
	print(Rhythia.record_mode,get_item_index(Rhythia.record_mode))
	selected = get_item_index(Rhythia.record_mode)
	connect("item_selected",self,"upd")
