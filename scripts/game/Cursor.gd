extends Spatial

var rpos:Vector2 = Vector2(transform.origin.x,-transform.origin.y)

enum {
	C_MOUSE = 0
	C_JOYSTICK = 1
}

var sh:Vector2 = Vector2(-0.5,-0.5)
var edgec:float = 0.13125
var edger:float = -Rhythia.get("edge_drift")
var face:Vector2

var move_mode:int = C_MOUSE
var can_switch_move_modes:bool = true

func drift_cursor(rx,ry,cx,cy):
	if Rhythia.enable_drift_cursor:
		if cx != rx or cy != ry:
			$Mesh2.visible = true
			$Mesh2.transform.origin.x = rx - cx
			$Mesh2.transform.origin.y = -(ry - cy)
		else: $Mesh2.visible = false

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

	drift_cursor(rx,ry,cx,cy)

func move_cursor_abs(mdel:Vector2):
	var rx = mdel.x
	var ry = mdel.y
	
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

	drift_cursor(rx,ry,cx,cy)


onready var absCamera = get_node("../../../AbsCamera")
func get_absolute_position():
	absCamera.fov = Rhythia.get("fov")
	var pos = absCamera.project_position(get_viewport().get_mouse_position(),3.75) * Rhythia.absolute_scale
	return Vector2(pos.x,-pos.y) + Vector2(1,1)

func _input(event:InputEvent):
	if !Rhythia.replaying and !Rhythia.vr:
		if can_switch_move_modes:
			if event is InputEventJoypadMotion:
				move_mode = C_JOYSTICK
			elif event is InputEventMouseMotion:
				move_mode = C_MOUSE
		
		if move_mode == C_JOYSTICK:
			var v_strength = (Input.get_action_strength("joy_up") + (Input.get_action_strength("joy_down") * -1)) * -1
			var h_strength = (Input.get_action_strength("joy_right") + (Input.get_action_strength("joy_left") * -1)) * 1
			var relative = Vector2(h_strength * 1.5,v_strength * 1.5)
			var off = Vector2(1,1)
			if Rhythia.invert_mouse:
				move_cursor_abs((relative + off) * -1)
			else:
				move_cursor_abs(relative + off)
		elif !Rhythia.get("cam_unlock") and move_mode == C_MOUSE:
			visible = true
			if (event is InputEventMouseMotion):
				face = event.relative
				if Rhythia.invert_mouse:
					if Rhythia.absolute_mode:
						move_cursor_abs(get_absolute_position() * -1)
					else:
						move_cursor((event.relative * 0.018 * Rhythia.sensitivity / Rhythia.render_scale) * -1)
				else:
					if Rhythia.absolute_mode:
						move_cursor_abs(get_absolute_position())
					else:
						move_cursor(event.relative * 0.018 * Rhythia.sensitivity / Rhythia.render_scale)
			
		if (event is InputEventScreenDrag):
			$VisualPos.visible = true
			$VisualPos.rect_position = event.position
		elif event is InputEventScreenTouch:
			$VisualPos.visible = event.pressed

var frame:int = Engine.get_frames_drawn()
var trail_cache:Array = []

var prev_pos
var prev_rot
var trail_started = false

var ct:float = 0
var segt:float = 0
var segl:float = 0.01

var total_trail_segments = 0

onready var trail_base = get_node("../../CursorTrail")

func cache_trail(part:Spatial):
	trail_cache.append(part)

func recolor(col:Color):
	$Mesh.get("material/0").albedo_color = Color(col.r,col.g,col.b,col.a)

var mt = 0
func _process(delta):
	if Input.is_action_just_pressed("debug_enable_mouse"):
		mt = mt + 1
		if mt == 1:
			Input.set_custom_mouse_cursor(null)
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if mt == 2:
			Input.set_custom_mouse_cursor(load("res://assets/images/ui/blank.png"))
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			if Rhythia.absolute_mode:
				Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mt = 0
	frame = Engine.get_frames_drawn()
	if Rhythia.cursor_spin != 0 and !Rhythia.cursor_face_velocity:
		$Mesh.rotate_z(deg2rad(-delta*Rhythia.cursor_spin))
		$Mesh2.rotate_z(deg2rad(-delta*Rhythia.cursor_spin))
	if Rhythia.cursor_face_velocity:
		$Mesh.rotation_degrees.x += ((rad2deg(face.angle()) + 180) - $Mesh.rotation_degrees.x) * 0.025
	if Rhythia.cursor_color_type == Globals.CURSOR_RAINBOW:
		$Mesh.get("material/0").albedo_color = Color.from_hsv(Rhythia.rainbow_t*0.1,0.65,1)
	if Input.is_key_pressed(KEY_C):
		ct = fmod(ct+delta,3)
		global_transform.origin = Vector3(ct-1.5,sin(ct*4),global_transform.origin.z)
	
	if Rhythia.replaying:
		var p
		if Rhythia.replay.sv == 1 or Rhythia.replay.autoplayer: p = Rhythia.replay.get_cursor_position(get_parent().ms)
		else: p = Rhythia.replay.get_cursor_position(get_parent().rms)
		if Rhythia.replay.sv < 3:
			transform.origin.x = p.x
			transform.origin.y = p.y
		else:
			move_cursor_abs(Vector2(p.x,p.y))
	
	if Rhythia.show_cursor and Rhythia.cursor_trail and Rhythia.smart_trail and trail_started:
		var start_p = global_transform.origin
		var end_p = prev_pos
		var start_r = $Mesh.rotation_degrees.x
		var end_r = prev_rot
		var p_diff = (start_p - end_p).length()
		var r_diff = PI * Rhythia.cursor_scale * abs(start_r - end_r)/360
		var diff = p_diff
		if r_diff > p_diff: diff = r_diff
		var amt = min(ceil(Rhythia.trail_detail*diff),120)
		var new = 0
		var cached = 0
		for i in range(amt):
			var trail:Spatial
			var v = float(i)/float(amt)
			var pos = lerp(start_p,end_p,v)
			var rot = lerp(start_r,end_r,v)
			if trail_cache.size() != 0:
				trail = trail_cache.pop_front()
				cached += 1
			else:
				trail = trail_base.duplicate()
				get_node("../..").add_child(trail)
				trail.connect("cache_me",self,"cache_trail",[trail])
				total_trail_segments += 1
				new += 1
			
			trail.start_smart(v*delta,pos,rot)
		if $L.visible:
			$L.text = "amount this frame: %s\nnewly spawned: %s\nfrom cache: %s\n\nwaiting: %s\nactive: %s\ntotal: %s" % [
				amt,
				new,
				cached,
				trail_cache.size(),
				total_trail_segments - trail_cache.size(),
				total_trail_segments
			]
		prev_pos = global_transform.origin
		prev_rot = $Mesh.rotation_degrees.x

func _ready():
	if !Rhythia.show_cursor: visible = false
	
	if !Rhythia.replaying:
		if not Rhythia.absolute_mode:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			Input.set_custom_mouse_cursor(load("res://assets/images/ui/blank.png"))
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	var mat:SpatialMaterial = $Mesh.get("material/0")
	$Mesh.scale = Vector3(Rhythia.cursor_scale,Rhythia.cursor_scale,Rhythia.cursor_scale)
	$Mesh2.scale = Vector3(Rhythia.cursor_scale,Rhythia.cursor_scale,Rhythia.cursor_scale)
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
	
	prev_pos = global_transform.origin
	prev_rot = $Mesh.rotation_degrees.x
	
	if Rhythia.cursor_color_type == Globals.CURSOR_NOTE_COLOR:
		recolor(Rhythia.selected_colorset.colors[-1])
		get_parent().connect("hit",self,"recolor")
	elif Rhythia.cursor_color_type == Globals.CURSOR_CUSTOM_COLOR:
		recolor(Rhythia.cursor_color)
	
	if Rhythia.cursor_trail:
		if Rhythia.smart_trail:
			yield(get_tree(),"idle_frame")
			for i in range(Rhythia.trail_detail * 3.5):
				var trail = trail_base.duplicate()
				get_node("../..").add_child(trail)
				trail.connect("cache_me",self,"cache_trail",[trail])
				trail_cache.append(trail)
				trail.start_smart(1,Vector3(0,0,-4),0)
		else:
			for i in range(Rhythia.trail_detail):
				var trail:Spatial = trail_base
				if i != 0:
					trail = trail.duplicate()
					get_node("../..").call_deferred("add_child",trail)
				trail.offset = (i) / float(Rhythia.trail_detail-1)
				trail.start()
	trail_started = true
func _exit_tree():
	for n in trail_cache:
		n.queue_free()
