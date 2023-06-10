extends Resource
class_name DanceMover

func update(ms:float) -> Vector2:
	return call("_update",ms)
