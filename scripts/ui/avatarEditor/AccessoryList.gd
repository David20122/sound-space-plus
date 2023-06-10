extends ItemList


func _on_List_item_activated(index):
	if get_parent().get_parent().get_node("VPContainer/VP/Avatar/Head/Accessories").has_node(get_item_text(index)):
		get_parent().get_parent().get_node("VPContainer/VP/Avatar/Head/Accessories").get_node(get_item_text(index)).visible = false
	elif get_parent().get_parent().get_node("VPContainer/VP/Avatar/Torso/Shirts").has_node(get_item_text(index)):
		get_parent().get_parent().get_node("VPContainer/VP/Avatar/Torso/Shirts").get_node(get_item_text(index)).visible = false
	remove_item(index)
