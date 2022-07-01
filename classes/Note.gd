class_name Note
extends Spatial

export(ShaderMaterial) var solid_mat
export(ShaderMaterial) var transparent_mat

var notems:float
var was_visible:bool = false
var state:int = 0
var spawn_effect_t:float = 0
onready var speed_multi:float = get_parent().speed_multi
var col:Color


var fade_in_enabled:bool = true
var fade_in_start:float = 8
var fade_in_end:float = 6

var fade_out_enabled:bool = false
var fade_out_start:float = 3
var fade_out_end:float = 1

var mat_s:ShaderMaterial
var mat_t:ShaderMaterial

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
		
		if fade_in_enabled or fade_out_enabled:
			var fade_in:float = 1
			var fade_out:float = 1
			
			if fade_in_enabled: 
				fade_in = smoothstep(fade_in_start,fade_in_end,current_dist)
			if fade_out_enabled:
				fade_out = smoothstep(fade_out_end,fade_out_start,current_dist)
			
			var alpha:float = min(fade_in,fade_out)
			
			$Mesh.visible = (alpha != 0)
			mat_s.set_shader_param("fade",alpha)
			mat_t.set_shader_param("fade",alpha)
			
		
		return true
	else:
		visible = false
		return !(state == Globals.NSTATE_ACTIVE and sign(approachSpeed) == 1 and current_dist > 100)

func check(cpos:Vector3):
	var hbs:float = SSP.note_hitbox_size/2
	if hbs == 0.57: hbs = 0.56875 # 1.1375
	var ori:Vector3 = transform.origin
	return (cpos.x <= ori.x + hbs and cpos.x >= ori.x - hbs) and (cpos.y <= ori.y + hbs and cpos.y >= ori.y - hbs)

func setup(color:Color):
	var mat2:SpatialMaterial = get_node("Spawn/Mesh").get_surface_material(0).duplicate()
	mat_s = solid_mat.duplicate()
	mat_t = transparent_mat.duplicate()
	$Mesh.set_surface_material(0,mat_s)
	if $Mesh.get_surface_material_count() != 0:
		$Mesh.set_surface_material(1,mat_t)
		$Mesh.set_surface_material(2,mat_s)
	get_node("Spawn/Mesh").set_surface_material(0,mat2)
	mat_s.set_shader_param("notecolor",color)
	mat_t.set_shader_param("notecolor",color)
	mat2.albedo_color = color
	col = color
	
	if SSP.mod_ghost:
		fade_out_enabled = true
		fade_out_start = ((18.0/50)*SSP.approach_rate)
		fade_out_end = ((6.0/50.0)*SSP.approach_rate)
	
	if SSP.mod_nearsighted:
		fade_in_enabled = true
		fade_in_start = ((30.0/50.0)*SSP.approach_rate)
		fade_in_end = ((5.0/50.0)*SSP.approach_rate)
	else:
		fade_in_enabled = SSP.fade_length != 0
		if SSP.fade_length != 0: 
			fade_in_start = SSP.spawn_distance
			fade_in_end = SSP.spawn_distance*(1.0 - SSP.fade_length)

func _process(delta):
	if visible:
		spawn_effect_t = max(0, spawn_effect_t - (4*delta))
		$Spawn.scale = Vector3(1*spawn_effect_t, 0.9 + (0.1*spawn_effect_t), 1)
		$Spawn.visible = spawn_effect_t != 0
