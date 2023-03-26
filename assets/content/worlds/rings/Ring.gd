extends Node3D

var game:GameScene

@export var ring_speed:float = 15

func _ready():
	game = $"../../".get_meta("game")

func _process(delta):
	transform.origin -= Vector3(0,0,delta*ring_speed*game.sync_manager.playback_speed)
	if transform.origin.z <= -45: transform.origin.z += 105
