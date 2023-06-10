extends Button

func _pressed():
	if get_parent().name == "Head" and get_parent().get_node("Input").text != "":
		if get_parent().get_parent().get_node("VPContainer/VP/Avatar/Head/Accessories").has_node(get_parent().get_node("Input").text):
			get_parent().get_parent().get_node("VPContainer/VP/Avatar/Head/Accessories").get_node(get_parent().get_node("Input").text).visible = true
		get_parent().get_node("List").add_item(get_parent().get_node("Input").text,null,true)
		get_parent().get_node("Input").text = ""
		
	elif get_parent().name == "Torso" and get_parent().get_node("Input").text != "":
		if get_parent().get_parent().get_node("VPContainer/VP/Avatar/Torso/Shirts").has_node(get_parent().get_node("Input").text):
			get_parent().get_parent().get_node("VPContainer/VP/Avatar/Torso/Shirts").get_node(get_parent().get_node("Input").text).visible = true
		get_parent().get_node("List").add_item(get_parent().get_node("Input").text,null,true)
		get_parent().get_node("Input").text = ""
