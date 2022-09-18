extends Spatial

var rpos:Vector2 = Vector2(transform.origin.x,-transform.origin.y)

var sh:Vector2 = Vector2(-0.5,-0.5)
var edgec:float = 0
var edger:float = -SSP.edge_drift
var face:Vector2

func move_cursor(mdel:Vector2):
	var rx = rpos.x
	var ry = rpos.y
	rx += mdel.x
	ry += mdel.y
	
	rx = clamp(rx, (0 + sh.x + edger), (3 + sh.x - edger))
	ry = clamp(ry, (0 + sh.y + edger), (3 + sh.y - edger))
	
	rpos.x = rx
	rpos.y = ry
	
	var cx = rx
	var cy = ry
	cx = clamp(cx, (0 + sh.x + edgec), (3 + sh.x - edgec))
	cy = clamp(cy, (0 + sh.y + edgec), (3 + sh.y - edgec))
	
	transform.origin.x = cx
	transform.origin.y = -cy
	
	if SSP.enable_drift_cursor:
		if cx != rx or cy != ry:
			$Mesh2.visible = true
			$Mesh2.transform.origin.x = rx - cx
			$Mesh2.transform.origin.y = -(ry - cy)
		else: $Mesh2.visible = false

func _input(event:InputEvent):
	if !SSP.replaying and !SSP.vr:
		if !SSP.cam_unlock:
			visible = true
			if (event is InputEventMouseMotion):
				face = event.relative
				move_cursor(event.relative * 0.018 * SSP.sensitivity)
		if (event is InputEventScreenDrag):
			$VisualPos.visible = true
			$VisualPos.rect_position = event.position
		elif event is InputEventScreenTouch:
			$VisualPos.visible = event.pressed

var frame:int = Engine.get_frames_drawn()
var trail_cache:Array = []

var prev_end
var trail_started = false

var ct:float = 0
var segt:float = 0
var segl:float = 0.01

var total_trail_segments = 0

onready var trail_base = get_node("../../CursorTrail")

func cache_trail(part:Spatial):
	trail_cache.append(part)

func _process(delta):
	
	if Input.is_action_just_pressed("debug_enable_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	frame = Engine.get_frames_drawn()
	if SSP.cursor_spin != 0 and !SSP.cursor_face_velocity:
		$Mesh.rotate_z(deg2rad(-delta*SSP.cursor_spin))
		$Mesh2.rotate_z(deg2rad(-delta*SSP.cursor_spin))
	if SSP.cursor_face_velocity:
		$Mesh.rotation_degrees.x += ((rad2deg(face.angle()) + 180) - $Mesh.rotation_degrees.x) * 0.025
	if SSP.rainbow_cursor:
		$Mesh.get("material/0").albedo_color = Color.from_hsv(SSP.rainbow_t*0.1,0.65,1)
	if Input.is_key_pressed(KEY_C):
		ct = fmod(ct+delta,3)
		global_transform.origin = Vector3(ct-1.5,sin(ct*4),global_transform.origin.z)
	
	if SSP.replaying:
		var p
		if SSP.replay.sv == 1 or SSP.replay.autoplayer: p = SSP.replay.get_cursor_position(get_parent().ms)
		else: p = SSP.replay.get_cursor_position(get_parent().rms)
		transform.origin.x = p.x
		transform.origin.y = p.y
	
	if SSP.show_cursor and SSP.cursor_trail and SSP.smart_trail and trail_started:
		var start_p = global_transform.origin
		var end_p = prev_end
		var amt = min(ceil(SSP.trail_detail*(start_p-end_p).length()),120)
		var new = 0
		var cached = 0
		for i in range(amt):
			var trail:Spatial
			var v = float(i)/float(amt)
			var pos = lerp(start_p,end_p,v)
			if trail_cache.size() != 0:
				trail = trail_cache.pop_front()
				cached += 1
			else:
				trail = trail_base.duplicate()
				get_node("../..").add_child(trail)
				trail.connect("cache_me",self,"cache_trail",[trail])
				total_trail_segments += 1
				new += 1
			
			trail.start_smart(v*delta,pos)
		if $L.visible:
			$L.text = "amount this frame: %s\nnewly spawned: %s\nfrom cache: %s\n\nwaiting: %s\nactive: %s\ntotal: %s" % [
				amt,
				new,
				cached,
				trail_cache.size(),
				total_trail_segments - trail_cache.size(),
				total_trail_segments
			]
		prev_end = global_transform.origin

func _ready():
	if !SSP.show_cursor: visible = false
	
	if !SSP.replaying:
		if SSP.lock_mouse:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			Input.set_custom_mouse_cursor(load("res://content/ui/blank.png"))
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	var mat:SpatialMaterial = $Mesh.get("material/0")
	$Mesh.scale = Vector3(SSP.cursor_scale,SSP.cursor_scale,SSP.cursor_scale)
	$Mesh2.scale = 0.5 * Vector3(SSP.cursor_scale,SSP.cursor_scale,SSP.cursor_scale)
	var img = Globals.imageLoader.load_if_exists("user://cursor")
	if img:
		mat.albedo_color = Color(1,1,1)
		mat.albedo_texture = img
	
	mat = get_node("../../CursorTrail/Mesh").get("material/0")
	var img2 = Globals.imageLoader.load_if_exists("user://trail")
	if img2: mat.albedo_texture = img2
	elif img: mat.albedo_texture = img
	
	img = Globals.imageLoader.load_if_exists("user://touch")
	if img: $VisualPos/T.texture = img
	
	$L.visible = ProjectSettings.get_setting("application/config/show_trail_debug")
	
	prev_end = global_transform.origin
	
	if SSP.cursor_trail and !SSP.smart_trail:
		for i in range(SSP.trail_detail):
			var trail:Spatial = trail_base
			if i != 0:
				trail = trail.duplicate()
				get_node("../..").call_deferred("add_child",trail)
			trail.offset = (i) / float(SSP.trail_detail-1)
			trail.start()
	trail_started = true
