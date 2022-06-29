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

func spawn(parent:Node,pos:Vector3,col:Color):
	var mat:SpatialMaterial = $Mesh.get("material/0").duplicate()
	$Mesh.set("material/0",mat)
	
	if SSP.selected_hit_effect.id == "ssp_ripple_n":
		mat.albedo_color = col
	elif SSP.selected_hit_effect.id == "ssp_ripple_r":
		mat.albedo_color = Color.from_hsv(SSP.rainbow_t*0.1,0.4,1)
	
	transform.origin = pos
	parent.add_child(self)
	active = true

var is_first:bool = true
func _ready():
	if !is_first: return
	is_first = false
	var img = Globals.imageLoader.load_if_exists("user://hit")
	if img:
		$Mesh.get("material/0").albedo_texture = img
