extends Spatial

var active:bool = false
var rainbow:bool = false

func _process(delta):
	if !active and rainbow:
		$Particles.material_override.albedo_color = Color.from_hsv(Rhythia.rainbow_t*0.1,0.4,1)
	if active:
		if $Particles.emitting == false:
			active = false
			queue_free()
			return

func get_color_mat(parent:Node,col:Color,miss:bool):
	var cache:Dictionary
	if miss: cache = parent.matcache_miss
	else: cache = parent.get_node("Spawn").matcache_hit
	
	var mat:SpatialMaterial
	if cache.get(col):
		mat = cache[col]
	else:
		mat = $Particles.material_override.duplicate()
		mat.albedo_color = col
		cache[col] = mat
		
	return mat

func spawn(parent:Node,pos:Vector3,col:Color,id:String,miss:bool):
	if id == "ssp_shards":
		$Particles.material_override = get_color_mat(parent,col,miss)
	
	transform.origin = pos
	parent.add_child(self)
	visible = true
	$Particles.emitting = true
	active = true

func setup(id:String,miss:bool):
	if id == "ssp_shards_r":
		print("RAINBOW")
		rainbow = true
