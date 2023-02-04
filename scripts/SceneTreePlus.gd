extends SceneTree
class_name SceneTreePlus

var fps_limit:int = 0

func _init():
	._init()

func _is_game_scene(scene):
	return false
	# return current_scene is GameScene
func _idle(delta):
	var fps = 90
	if _is_game_scene(current_scene):
		fps = fps_limit
	elif fps_limit != 0:
		fps = min(fps_limit,90)
	if !OS.is_window_focused():
		fps /= 3
	print(fps)
	Engine.target_fps = fps
