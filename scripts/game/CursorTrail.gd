extends Spatial

signal cache_me

export(float) var offset = 0

var started:bool = false
var t:float = 0

onready var cursor = get_node("../Spawn/Cursor")
onready var cursormesh = get_node("../Spawn/Cursor/Mesh")

var last_origin = Vector3(-100,0,0)
var before
var can_reuse:bool = false
var transp_multi = 1


func respawn(t_override=null,rot=0):
	if t_override:
		visible = true
		global_transform.origin = t_override
		$Mesh.rotation_degrees.x = rot
	else:
		visible = (cursor.global_transform.origin - Vector3(0,0,0.001)) != last_origin
		global_transform.origin = cursor.global_transform.origin - Vector3(0,0,0.001)
		if Input.is_key_pressed(KEY_V):
			global_transform.origin = Vector3((offset*3)-1.5,(offset*3)-1.5,-0.2)
	
	$Mesh.get("material/0").albedo_color = cursormesh.get("material/0").albedo_color
	$Mesh.rotation = cursormesh.rotation

func upd_dumb(delta):
	if !Rhythia.smart_trail:
		t += (delta/Rhythia.trail_time)
	var a = clamp((t - 0.2),0,1)
	if Rhythia.trail_mode_opacity:
		$Mesh.get("material/0").albedo_color.a = a * 0.6 * transp_multi
	if Rhythia.trail_mode_scale:
		$Mesh.scale = Vector3(a*Rhythia.cursor_scale,1,a*Rhythia.cursor_scale)
	if !Rhythia.smart_trail and t >= 1:
		t -= 1
		respawn()

func update(delta):
	t -= (delta/Rhythia.trail_time)
	var a = clamp((t),0,1)
	if Rhythia.trail_mode_opacity:
		$Mesh.get("material/0").albedo_color.a = a * 0.6 * transp_multi
	if Rhythia.trail_mode_scale:
		$Mesh.scale = Vector3(a*Rhythia.cursor_scale,1,a*Rhythia.cursor_scale)
	if t <= 0:
		started = false
		visible = false
		emit_signal("cache_me")

func _process(delta):
	if started:
		if Rhythia.smart_trail: update(delta)
		else: upd_dumb(delta)

var init_done:bool = false
func init():
	if init_done: return
	init_done = true
	var mat:SpatialMaterial = $Mesh.get("material/0").duplicate()
	$Mesh.scale = Vector3(0,1,0)
	if not Rhythia.trail_mode_scale:
		$Mesh.scale = Vector3(Rhythia.cursor_scale,1,Rhythia.cursor_scale)
	$Mesh.set("material/0",mat)

func start():
	init()
	t = -offset
	started = true


func start_smart(v:float,pos:Vector3,rot:float):
	init()
	started = true
	t = 1 - v
	respawn(pos,rot)
