extends CheckBox

func _pressed():
	get_parent().get_parent().get_node("S/G").update_search_showbroken(
		!get_parent().get_parent().get_node("S/G").show_broken_maps
	)
	SSP.last_search_incl_broken = pressed

func _ready():
	pressed = SSP.last_search_incl_broken
	get_parent().get_parent().get_node("S/G").update_search_showbroken(
		SSP.last_search_incl_broken
	)
