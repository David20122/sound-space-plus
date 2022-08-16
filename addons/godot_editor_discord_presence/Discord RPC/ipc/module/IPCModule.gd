class_name IPCModule

var _ipc: IPC

var name: String

func _init(_name: String) -> void:
	self.name = _name

func initilize(ipc: IPC) -> void:
	self._ipc = ipc

func get_functions() -> PoolStringArray:
	return PoolStringArray()

func requires_authorize() -> bool:
	return false
