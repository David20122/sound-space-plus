extends GameScene
class_name MultiGameScene

@export_node_path("Node3D") var root_path
@onready var multi_scene:MultiScene = get_node(root_path)
var network_player:Player

func setup_managers():
	super.setup_managers()
	if local_player: get_node("HUDManager").prepare(self)

func _ready():
	mods = multi_scene.mods
	mapset = multi_scene.mapset
	map_index = multi_scene.map_index
	settings = SoundSpacePlus.settings
	super._ready()
	if local_player: multi_scene.call_deferred("rpc","done")
