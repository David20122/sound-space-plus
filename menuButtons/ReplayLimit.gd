extends OptionButton

func upd(value):
	SSP.record_limit = get_item_id(value)

func _process(_d):
	if get_item_id(selected) != SSP.record_limit: upd(selected)
	
func _ready():
	selected = get_item_index(SSP.record_limit)
	connect("item_selected",self,"upd")
