extends Spatial

var active:bool = false
var t:float = 0.3
func _process(delta):
	if active:
		t += delta
		if t >= 0.6:
			active = false
			queue_free()
			return
		$Mesh.scale = Vector3(t*1.2,t*1.2,1)
		$Mesh.get("material/0").albedo_color.a = 1.0 - (t/0.6)

func spawn(parent:Node,pos:Vector3,col:Color):
	$Mesh.set("material/0",$Mesh.get("material/0").duplicate())
	transform.origin = pos
	parent.add_child(self)
	active = true
