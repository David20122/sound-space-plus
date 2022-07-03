extends Label

var lifted = false
var mouseinside = false

func _input(event):
	if lifted and event is InputEventMouseMotion:
		get_parent().rect_position += event.relative
	if event is InputEventMouseButton && event.get_button_index() == 1:
		if event.pressed:
			if event.position.x >= rect_global_position.x and event.position.x <= rect_global_position.x + rect_size.x and event.position.y >= rect_global_position.y and event.position.y <= rect_global_position.y + rect_size.y:
				lifted = true
		else:
			lifted = false
