extends Spatial

export var lspd = 0.01
var target:Vector3

func _process(delta):
	target = Vector3(
		$"../Spawn/Cursor/Mesh".global_translation.x,
		$"../Spawn/Cursor/Mesh".global_translation.y,
		-0.1
	)
	global_translation = lerp(global_translation,target,lspd)
