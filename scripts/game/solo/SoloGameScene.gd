extends GameScene

@export var hud_manager_path:NodePath
@onready var hud_manager:HUDManager = get_node(hud_manager_path)

@export_node_path("Node3D") var world_path
@onready var world_parent:Node3D = get_node(world_path)

func setup_managers():
	super.setup_managers()
	hud_manager.prepare(self)

func ready():
	set_meta("is_game",true)
	
	var world = SoundSpacePlus.worlds.items.front()
	var selected_world = settings.assets.world
	var ids = SoundSpacePlus.worlds.get_ids()
	if ids.has(selected_world):
		world = SoundSpacePlus.worlds.get_by_id(selected_world)
	if world != null:
		var world_node = world.load_world()
		world_node.set_meta("game",self)
		world_parent.add_child(world_node)
	
	sync_manager.call_deferred("start",-2 * sync_manager.playback_speed)
	
	player.connect("failed",Callable(self,"finish").bind(true))

var ended:bool = false
func finish(failed:bool=false):
	if ended: return
	ended = true
	print("failed: %s" % failed)
	if failed:
		print("fail animation")
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(sync_manager,"playback_speed",0,2)
		tween.play()
		await tween.finished
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
