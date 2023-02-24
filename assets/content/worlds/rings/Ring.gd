extends Node3D

func _ready():
	var game = $"../../../".manager.game

func _process(delta):
	transform.origin -= Vector3(0,0,delta*5)
	if transform.origin.z <= -45: transform.origin.z += 105
