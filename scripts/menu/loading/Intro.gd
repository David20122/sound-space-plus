extends Node3D

var running = false
var panning = false
var ifading = false
var fading = false
var can_skip = false
var can_skip2 = false

func _ready():
	
	# fix hands
	$Avatar/ArmL/Pointer.position = Vector3(0,0,0)
	$Avatar/ArmR/Mesh.position = Vector3(0,0,0)
	
	$ColorRect.modulate.a = 1
#	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (true) else Window.MODE_WINDOWED
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	await get_tree().create_timer(1).timeout
	running = true
	$Avatar/Animations.play("Float")
	$Avatar/Animations.playback_speed = 1
	$Camera2.rotation_degrees.y = 0
	await get_tree().create_timer(1).timeout
	$AudioStreamPlayer.play()
	can_skip = true
	await get_tree().create_timer(6.5).timeout
	$Camera3D.current = false
	$Camera2.current = true
	panning = true
	can_skip2 = true
	await get_tree().create_timer(14).timeout
	fading = true
	await get_tree().create_timer(4).timeout
	get_tree().change_scene_to_file("res://scenes/Init.tscn")

func _input(event):
	if Input.is_action_just_pressed("pause") and can_skip:
		get_tree().change_scene_to_file("res://scenes/Init.tscn")

func _process(delta):
	
	$Sprite3D.rotation_degrees.z += 16 * delta
	$Sprite3D2.rotation_degrees.z += 8 * delta
	$Sprite3D3.rotation_degrees.z += 4 * delta
	
	if running and not fading:
		$ColorRect.modulate.a += (0 - $ColorRect.modulate.a) * 0.4 * delta
	if panning:
		$Camera2.position.y += (12 - $Camera2.position.y) * 0.3 * delta
		$Camera2.rotation_degrees.y += (180 - $Camera2.rotation_degrees.y) * 0.4 * delta
	if fading:
		$ColorRect.modulate.a += (1 - $ColorRect.modulate.a) * 2 * delta
		$Skip.modulate.a += (0 - $Skip.modulate.a) * 2 * delta
	if can_skip2 and not fading:
		$Skip.modulate.a += (0.5 - $Skip.modulate.a) * 1 * delta

func _exit_tree():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
