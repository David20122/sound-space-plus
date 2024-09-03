extends Spatial

func _process(delta):
	var grandparent = get_parent().get_parent()
	if grandparent.has_node("Spawn/Cursor"):
		var cursor = grandparent.get_node("Spawn/Cursor")
		look_at(cursor.translation - Vector3(2, 0, 0), Vector3.UP)
