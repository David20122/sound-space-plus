extends Spatial

export(bool) var half_lock = true

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
	if !SSP.cam_unlock:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			move_cursor(Vector2(1,1) - Vector2(transform.origin.x,-transform.origin.y))
			visible = false
			return
		visible = true
		if event is InputEventMouseMotion:
			var ev:InputEventMouseMotion = event
			face = ev.relative
			move_cursor(ev.relative * 0.018 * SSP.sensitivity)

func _process(delta):
	if SSP.cursor_spin != 0 and !SSP.cursor_face_velocity:
		$Mesh.rotate_z(deg2rad(-delta*SSP.cursor_spin))
		$Mesh2.rotate_z(deg2rad(-delta*SSP.cursor_spin))
	if SSP.cursor_face_velocity:
		$Mesh.rotation_degrees.x += ((rad2deg(face.angle()) + 180) - $Mesh.rotation_degrees.x) * 0.025

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var mat:SpatialMaterial = $Mesh.get("material/0")
	$Mesh.scale = Vector3(SSP.cursor_scale,SSP.cursor_scale,SSP.cursor_scale)
	$Mesh2.scale = 0.5 * Vector3(SSP.cursor_scale,SSP.cursor_scale,SSP.cursor_scale)
	var img = Globals.imageLoader.load_if_exists("user://cursor")
	if img:
		mat.albedo_color = Color(1,1,1)
		mat.albedo_texture = img
