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

@export var has_map:bool = false
