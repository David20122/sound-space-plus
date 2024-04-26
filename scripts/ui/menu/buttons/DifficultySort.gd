extends CheckBox

func _pressed():
	get_parent().get_parent().get_node("MapRegistry/S/VBoxContainer").update_search_flipped(
		!get_parent().get_parent().get_node("MapRegistry/S/VBoxContainer").flip_display
	)
	Rhythia.last_search_flip_sort = pressed

func _ready():
	pressed = Rhythia.last_search_flip_sort
	get_parent().get_parent().get_node("MapRegistry/S/VBoxContainer").update_search_flipped(
		Rhythia.last_search_flip_sort
	)
