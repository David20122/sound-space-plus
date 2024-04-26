extends CheckBox

func _pressed():
	get_parent().get_parent().get_node("MapRegistry/S/VBoxContainer").update_search_showonline(
		!get_parent().get_parent().get_node("MapRegistry/S/VBoxContainer").show_online_maps
	)
	Rhythia.last_search_incl_online = pressed

func _ready():
	pressed = Rhythia.last_search_incl_online
	get_parent().get_parent().get_node("MapRegistry/S/VBoxContainer").update_search_showonline(
		Rhythia.last_search_incl_online
	)
