extends CheckBox

func _pressed():
	get_parent().get_parent().get_node("MapRegistry/S/VBoxContainer").update_search_showbroken(
		!get_parent().get_parent().get_node("MapRegistry/S/VBoxContainer").show_broken_maps
	)
	Rhythia.last_search_incl_broken = pressed

func _ready():
	pressed = Rhythia.last_search_incl_broken
	get_parent().get_parent().get_node("MapRegistry/S/VBoxContainer").update_search_showbroken(
		Rhythia.last_search_incl_broken
	)
