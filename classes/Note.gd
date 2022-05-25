class_name Note
extends Spatial

var notems:float
var was_visible:bool = false
var state:int = 0
var spawn_effect_t:float = 0
onready var speed_multi:float = get_parent().speed_multi
var col:Color

func reposition(ms:float,approachSpeed:float):
	approachSpeed /= speed_multi
	var current_offset_ms = notems-ms
	var current_dist = approachSpeed*current_offset_ms/1000
	if (
		(current_dist <= SSP.spawn_distance and current_dist >= -0.1 and sign(approachSpeed) == 1) or
		(current_dist >= -50 and current_dist <= 0.1 and sign(approachSpeed) == -1) or
		sign(approachSpeed) == 0
	) and state == Globals.NSTATE_ACTIVE: # state 2 = miss # and current_dist >= -0.5
		if !was_visible:
			was_visible = true
			if SSP.note_spawn_effect:
				if !SSP.mod_nearsighted: spawn_effect_t = 1
		if state == Globals.NSTATE_ACTIVE:
			transform.origin.z = -current_dist
			visible = true
			
		return true
	else:
		visible = false
		return !(state == Globals.NSTATE_ACTIVE and sign(approachSpeed) == 1 and current_dist > 100)

func check(cpos:Vector3):
	var hbs:float = SSP.note_hitbox_size/2
	var ori:Vector3 = transform.origin
	return (cpos.x <= ori.x + hbs and cpos.x >= ori.x - hbs) and (cpos.y <= ori.y + hbs and cpos.y >= ori.y - hbs)

func setup(color:Color):
	var mat:SpatialMaterial = $Mesh.get_surface_material(0).duplicate()
	var mat2:SpatialMaterial = get_node("Spawn/Mesh").get_surface_material(0).duplicate()
	$Mesh.set_surface_material(0,mat)
	get_node("Spawn/Mesh").set_surface_material(0,mat2)
	mat.albedo_color = color
	mat2.albedo_color = color
	col = color

func _process(delta):
	if visible:
		spawn_effect_t = max(0, spawn_effect_t - (4*delta))
		$Spawn.scale = Vector3(1*spawn_effect_t, 0.9 + (0.1*spawn_effect_t), 1)
		$Spawn.visible = spawn_effect_t != 0
