extends CheckBox

func _pressed():
	get_parent().get_parent().get_node("S/G").update_search_showonline(
		!get_parent().get_parent().get_node("S/G").show_online_maps
	)
	SSP.last_search_incl_online = pressed

func _ready():
	pressed = SSP.last_search_incl_online
	get_parent().get_parent().get_node("S/G").update_search_showonline(
		SSP.last_search_incl_online
	)
