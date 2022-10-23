extends WorldEnvironment


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var time = 0;
var rng = RandomNumberGenerator.new()
var initial_translation = Vector3(0.0, 0.0, 0.0)
var display_shader:Shader = load("res://content/worlds/security_room/monitor.gdshader")
var flicker_time = 0.0
var flicker_delay = 0.0
var flicker_intensity = 1.0
var last_flicker = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	initial_translation = get_node("/root/Song/Camera").translation
	get_node("/root/Song/Game/Avatar").visible = true
	get_node("/root/Song/Game/Avatar/Animations").play("Idle")
	get_node("/root/Song/Game/Avatar/Head/Blinking").play("Blink")
	get_node("/root/Song/Game/Avatar").translation = Vector3(-500.0, 0.0, 2.0)
	get_node("/root/Song/Game/Avatar").scale = Vector3(3, 3, 3)
	
func _process(delta):
	$Viewport5/Camera5.translation = get_node("/root/Song/Camera").translation
	get_node("/root/Song/Camera").translation = Vector3(-500.008, 0, -0.285) + initial_translation
	get_node("/root/Song/Game/Spawn/Hit").translation += Vector3(-500.008, 0, -0.285)
	get_node("/root/Song/Game/Spawn/Miss").translation += Vector3(-500.008, 0, -0.285)
	time += delta
	# Flicker light
	if time > last_flicker + flicker_delay:
		$NeonLight.light_energy = flicker_intensity
		if time > last_flicker + flicker_delay + flicker_time:
			last_flicker = time
			flicker_time = rng.randf_range(0.01, 0.3)
			flicker_delay = rng.randf_range(0.2, 10.0)
			flicker_intensity = rng.randf_range(0.2, 0.6)
			print("flicker",flicker_time,flicker_delay,flicker_intensity)
			$NeonLight.light_energy = 1
