extends CheckBox

func _pressed():
	get_parent().get_parent().get_node("S/G").update_search_flipped(
		!get_parent().get_parent().get_node("S/G").flip_display
	)
	SSP.last_search_flip_sort = pressed

func _ready():
	pressed = SSP.last_search_flip_sort
	get_parent().get_parent().get_node("S/G").update_search_flipped(
		SSP.last_search_flip_sort
	)
