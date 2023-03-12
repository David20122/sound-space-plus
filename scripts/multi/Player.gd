extends Node
class_name Player

var id:int:
	get: return name.to_int()
	set(value):
		id = value
		name = str(value)
var connected:bool = true

@export var nickname:String
@export var color:Color
@export var accuracy:String
@export var misses:String

@export var has_map:bool = false
@rpc("any_peer","call_local","reliable")
func set_has_map(_has_map:bool):
	if Multiplayer.api.get_remote_sender_id() != id: return
	if Multiplayer.api.get_unique_id() != 1: return
	has_map = _has_map
