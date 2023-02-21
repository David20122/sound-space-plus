extends SceneTree
class_name SceneTreePlus

var fps_limit:int = 0

func _init():
	root.set_script(preload("res://scripts/ViewportPlus.gd") as Script)
	super._init()
	root.get_window().title = "Sound Space Plus Rewritten"
	root.get_window().min_size = Vector2(640,640)
	root.get_window().move_to_foreground()

func change_scene_to_node(node:Node):
	call_deferred("_change_scene_to_node",node)
func _change_scene_to_node(node:Node):
	unload_current_scene()
	current_scene = node
	root.add_child(node)

func _is_game_scene(scene=current_scene):
	return scene is GameScene
func _idle(_delta):
	var fps = 90
	if _is_game_scene(current_scene):
		fps = fps_limit
	elif fps_limit != 0:
		fps = min(fps_limit,90)
	if !root.get_window().has_focus():
		fps = 30
	Engine.max_fps = fps

var quitting = false
func _set_master_volume(volume:float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Space Plus"),linear_to_db(volume))
func quit_animated(exit_code:int=0):
	if ProjectSettings.get_setting_with_override("application/outro/disabled"):
		quit()
		return
	if quitting:
		return
	quitting = true
	var viewport = root
	var container = SubViewportContainer.new()
	var fakeport = SubViewport.new()
	fakeport.size = viewport.size
	container.add_child(fakeport)
	container.anchor_top = 0
	container.anchor_left = 0
	container.anchor_bottom = 1
	container.anchor_right = 1
	container.size = viewport.size
	viewport.add_child(container)
	var scene = current_scene
	viewport.remove_child(scene)
	fakeport.add_child(scene)
	viewport.transparent_bg = true
	if ProjectSettings.get_setting_with_override("application/outro/play_sound"):
		var voice_player = AudioStreamPlayer.new()
		voice_player.bus = "Awesome!"
		var voice = preload("res://assets/sounds/death.mp3") as AudioStream
		voice_player.stream = voice
		viewport.add_child(voice_player)
		voice_player.play()
	var tween = create_tween()
	tween.set_parallel()
	tween.parallel().tween_property(container,"modulate:a",0,1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_method(Callable(self,"_set_master_volume"),1,0,0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.play()
	await tween.finished
	quit(exit_code)
