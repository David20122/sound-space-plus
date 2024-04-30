extends CheckBox

export(String) var target

func upd():
#	print('scb "%s"' % name)
	pressed = Rhythia.get(target)

func _pressed():
	if pressed != Rhythia.get(target):
		Rhythia.set(target,pressed)
	get_parent().get_parent().get_node("MapRegistry/S/VBoxContainer").update_search_showonline(
		Rhythia.last_search_incl_online
	)
	Rhythia.last_search_incl_online = pressed

func _ready():
	upd()
	get_parent().get_parent().get_node("MapRegistry/S/VBoxContainer").update_search_showonline(
		Rhythia.last_search_incl_online
	)
