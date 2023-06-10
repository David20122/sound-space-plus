extends Spatial

export var lspd = 0.025 # lerp speed
var target:Vector3 # general target
var tps:float # target pixel scale
var top:float # target opacity
onready var Game:SongPlayerManager = $".." # game instance (to detect combo)

func _process(delta):
	
	# set lerp targets
	target = Vector3(
		$"../Spawn/Cursor/Mesh".global_translation.x,
		$"../Spawn/Cursor/Mesh".global_translation.y,
		-0.1
	)
	if SSP.get("cam_unlock") == true:
		if Game.combo >= 100:
			tps = 0.025
			top = 1 # # opacity always 1 no matter what because fog thinks it cring! (keeping variable incase)
		elif Game.combo >= 50:
			tps = 0.0275
			top = 1 # opacity always 1 no matter what because fog thinks it cring! (keeping variable incase)
		else:
			tps = 0.03
			top = 1 # # opacity always 1 no matter what because fog thinks it cring! (keeping variable incase)
	else:
		if Game.combo >= 100:
			tps = 0.0125
			top = 1 # # opacity always 1 no matter what because fog thinks it cring! (keeping variable incase)
		elif Game.combo >= 50:
			tps = 0.015
			top = 1 # opacity always 1 no matter what because fog thinks it cring! (keeping variable incase)
		else:
			tps = 0.02
			top = 1 # # opacity always 1 no matter what because fog thinks it cring! (keeping variable incase)
	
	# application onto nodes
	global_translation = lerp(global_translation,target,lspd*40) # lspd multiplied by 40 to increase speed
	$Sprite.pixel_size = lerp($Sprite.pixel_size,tps,lspd/2) # lspd divided by 2 to increase time
	$Sprite.opacity = lerp($Sprite.opacity,top,lspd/2) # lspd divided by 2 to increase time
	
