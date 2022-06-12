extends Spatial

var active:bool = false
var t:float = 0.3
func _process(delta):
	if active:
		t += delta * 2.0
		if t >= 0.6:
			active = false
			queue_free()
			return
		$Mesh.scale = Vector3(t*1.2,t*1.2,1)
		$Mesh.get("material/0").albedo_color.a = 0.6 - t

func spawn(spawn:Node,pos:Vector3):
	$Mesh.set("material/0",$Mesh.get("material/0").duplicate())
	transform.origin = pos
	spawn.add_child(self)
	active = true

var is_first:bool = true
func _ready():
	if !is_first: return
	is_first = false
	var img = Globals.imageLoader.load_if_exists("user://hit")
	if img:
		$Mesh.get("material/0").albedo_texture = img
