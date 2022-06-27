extends Spatial

export(float) var offset = 0.1

var started:bool = false
var t:float = 0

onready var cursor = get_node("../Cursor")
onready var cursormesh = get_node("../Cursor/Mesh")

func respawn():
	visible = true
	transform.origin = cursor.transform.origin
	$Mesh.get("material/0").albedo_color = cursormesh.get("material/0").albedo_color
	$Mesh.rotation = cursormesh.rotation

func _process(delta):
	if started:
		t += (delta*6)
		var a = clamp(1-t,0,1)
		$Mesh.get("material/0").albedo_color.a = a * 0.6
		$Mesh.scale = Vector3(a*SSP.cursor_scale,1,a*SSP.cursor_scale)
		if t >= 1:
			t -= 1
			respawn()

func start():
	var mat:SpatialMaterial = $Mesh.get("material/0").duplicate()
	$Mesh.set("material/0",mat)
	t = -offset
	started = true
