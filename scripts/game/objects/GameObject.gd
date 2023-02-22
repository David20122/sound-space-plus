extends Node3D
class_name GameObject

var game:GameScene
var manager:ObjectManager

@export var id:String
@export var permanent:bool = false
@export var spawn_time:float = 0
@export var despawn_time:float = 0

func _init(_id:String=name):
	id = _id

func _process(_delta):
	if game == null or manager == null: return
	update(game.sync_manager.current_time)

func update(current_time:float):
	pass
