extends Spatial

var active:bool = false

func _process(delta):
	if active:
		if $Particles.emitting == false:
			active = false
			queue_free()
			return

func spawn(parent:Node,pos:Vector3,col:Color):
	var mesh = $Particles.get("draw_pass_1").duplicate()
	$Particles.set("draw_pass_1",mesh)
	mesh.material = mesh.material.duplicate()
	
	if SSP.selected_hit_effect.id == "ssp_shards":
		mesh.material.albedo_color = col
	elif SSP.selected_hit_effect.id == "ssp_shards_r":
		mesh.material.albedo_color = Color.from_hsv(SSP.rainbow_t*0.1,0.4,1)
	
	transform.origin = pos
	parent.add_child(self)
	$Particles.emitting = true
	active = true

var is_first:bool = true
func _ready():
	if !is_first: return
	is_first = false
#	var img = Globals.imageLoader.load_if_exists("user://hit")
#	if img:
#		$Mesh.get("material/0").albedo_texture = img
