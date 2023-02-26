extends Control

var cooldown = 0

func _ready():
	modulate.a = 0
	mouse_filter = Control.MOUSE_FILTER_PASS
	set_process_input(false)
	visible = true
	$Panel/Buttons/Resume.connect("pressed",Callable(self,"attempt_resume"))
	$Panel/Buttons/Restart.connect("pressed",Callable(self,"attempt_restart"))
	$Panel/Buttons/Return.connect("pressed",Callable(self,"attempt_return"))

func _process(_delta):
	var paused = get_tree().paused
	if Input.is_action_just_pressed("pause"):
		print("Just pressed pause")
		if !paused:
			attempt_pause()
		else:
			attempt_resume()

var tween:Tween
func attempt_pause():
	print("Pausing")
	if get_tree().paused: return
	var now = Time.get_ticks_msec()
	if (now - cooldown) < 150: return
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process_input(true)
	Input.warp_mouse(get_viewport_rect().size*0.5)
	if tween != null: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"modulate:a",1,0.4)
	tween.play()
func attempt_resume():
	print("Resuming")
	if !get_tree().paused: return
	var now = Time.get_ticks_msec()
	cooldown = now
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_filter = Control.MOUSE_FILTER_PASS
	set_process_input(false)
	if tween != null: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"modulate:a",0,0.4)
	tween.play()
	await get_tree().create_timer(0.4).timeout
	await tween.finished
	get_tree().paused = false
func attempt_restart():
	print("Restarting")
	if !get_tree().paused: return
	mouse_filter = Control.MOUSE_FILTER_PASS
	set_process_input(false)
	get_parent().process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	var game_scene = SoundSpacePlus.load_game_scene(SoundSpacePlus.GameType.SOLO,get_parent().mapset,get_parent().map_index)
	get_tree().change_scene_to_node(game_scene)
func attempt_return():
	print("Returning")
	get_parent().process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
