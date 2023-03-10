extends Node
class_name Player

var id:int:
	get: return id
	set(value):
		id = value
		name = str(value)
var connected:bool = true

@export var nickname:String
@export var color:Color
