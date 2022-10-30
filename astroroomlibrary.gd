extends Spatial

var running = false
var panning = false
var fading = false
var can_skip = false
var can_skip2 = false

func _ready():
	$ColorRect.modulate.a = 1
	OS.window_fullscreen = true
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	yield(get_tree().create_timer(2),"timeout")
	running = true
	$Avatar/Animations.play("Sleepy")
	$Avatar.translation.y = -1
	$SpotLight.omni_range = 0
	$ColorRect.modulate.a = 0
	yield(get_tree().create_timer(1),"timeout")
	$AudioStreamPlayer.play()
	can_skip = true
	yield(get_tree().create_timer(6.5),"timeout")
	$Camera.current = false
	$Camera2.current = true
	panning = true
	can_skip2 = true
	yield(get_tree().create_timer(14),"timeout")
	fading = true
	yield(get_tree().create_timer(4),"timeout")
	get_tree().change_scene("res://init.tscn")

func _input(event):
	if Input.is_action_just_pressed("pause") and can_skip:
		get_tree().change_scene("res://init.tscn")

func _process(delta):
	
	$Sprite3D.rotation_degrees.z += 8 * delta
	$Sprite3D2.rotation_degrees.z += 6 * delta
	$Sprite3D3.rotation_degrees.z += 4 * delta
	
	if running:
		$Avatar.translation.y += (0.6 - $Avatar.translation.y) * 0.001
		$SpotLight.omni_range += (10 - $SpotLight.omni_range) * 0.0005
	if panning:
		$Camera2.translation.y += (12 - $Camera2.translation.y) * 0.00035
	if fading:
		$ColorRect.modulate.a += (1 - $ColorRect.modulate.a) * 0.005
		$Skip.modulate.a += (0 - $Skip.modulate.a) * 0.005
	if can_skip2 and not fading:
		$Skip.modulate.a += (0.5 - $Skip.modulate.a) * 0.0005
