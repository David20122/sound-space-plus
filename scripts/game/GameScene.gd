extends Spatial
class_name GameScene

export(NodePath) var sync_manager
export(NodePath) var note_manager
export(NodePath) var hud_manager
export(NodePath) var camera

func _ready():
	sync_manager.get_node()