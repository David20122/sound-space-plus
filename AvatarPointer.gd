extends Spatial

func _physics_process(delta):
	look_at(get_parent().get_parent().get_node("Spawn/Cursor").translation,translation)
