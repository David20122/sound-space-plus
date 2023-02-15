extends OptionButton

func upd(value):
	SSP.record_mode = get_item_id(value)

func _process(_d):
	if get_item_id(selected) != SSP.record_mode: upd(selected)
	
func _ready():
	print(SSP.record_mode,get_item_index(SSP.record_mode))
	selected = get_item_index(SSP.record_mode)
	connect("item_selected",self,"upd")
