class_name UnixPipe extends IPCPipe

var _peer: StreamPeerUnix

func open(path: String) -> int:
	_peer = StreamPeerUnix.new()
	return _peer.open(path)

func read() -> Array:
	var op_code: int = _peer.get_32()
	var length: int = _peer.get_32()
	var buffer: PoolByteArray = _peer.get_data(length)[1]
	return [op_code, buffer]

func write(bytes: PoolByteArray) -> void:
	_peer.put_data(bytes)

func is_open() -> bool:
	return _peer and _peer.is_open()

func has_reading() -> bool:
	return _peer.get_available_bytes() > 0

func close() -> void:
	if _peer and _peer.is_open():
		_peer.close()
	_peer = null

func _to_string() -> String:
	return "[UnixPipe:%d]" % self.get_instance_id()
