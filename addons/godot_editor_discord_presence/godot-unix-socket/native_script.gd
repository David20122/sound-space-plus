tool
extends NativeScript

const LIBRARY: GDNativeLibrary = preload("unix-socket.gdnlib")
const SUPPORTED_PLATFORMS := PoolStringArray([
	"OSX",
	"Server",
	"X11"
])

func _init() -> void:
	if OS.get_name() in SUPPORTED_PLATFORMS:
		library = LIBRARY

func _get_property_list() -> Array:
	return [{
		name = "script",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_string = "Script",
		usage = PROPERTY_USAGE_DEFAULT
	}]
