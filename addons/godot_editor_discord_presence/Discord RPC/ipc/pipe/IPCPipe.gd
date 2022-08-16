class_name IPCPipe

func open(_path: String) -> int:
	return ERR_UNAVAILABLE

func read() -> Array:
	return []

func write(_bytes: PoolByteArray) -> void:
	pass

func is_open() -> bool:
	return false

func has_reading() -> bool:
	return false

func close() -> void:
	pass

func _to_string() -> String:
	return "[IPCPipe:%d]" % self.get_instance_id()
