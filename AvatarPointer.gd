extends Spatial

func _process(delta):
	look_at(get_parent().get_parent().get_node("Spawn/Cursor").translation,Vector3.UP)
