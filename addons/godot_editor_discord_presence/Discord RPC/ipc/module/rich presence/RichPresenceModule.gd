class_name RichPresenceModule extends IPCModule


func _init().("RichPresence") -> void:
	pass

func get_functions() -> PoolStringArray:
	return PoolStringArray(["update_presence"])

func update_presence(presence: RichPresence) -> void:
	var request: IPCPayload = UpdateRichPresencePayload.new(presence)
	self._ipc.send(request)
