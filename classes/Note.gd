class_name Note
extends Spatial

export(ShaderMaterial) var solid_mat
export(ShaderMaterial) var transparent_mat

var notems:float
var was_visible:bool = false
var id:int = -1
var state:int = 0
var spawn_effect_t:float = 0
onready var speed_multi:float = get_parent().speed_multi
var col:Color

var chaos_offset:Vector2 = Vector2()
var real_position:Vector2 = Vector2()

var fade_in_enabled:bool = true
var fade_in_start:float = 8
var fade_in_end:float = 6

var fade_out_enabled:bool = false
var fade_out_start:float = 3
var fade_out_end:float = 1

var mat_s:ShaderMaterial
var mat_t:ShaderMaterial

func linstep(a:float,b:float,x:float):
	if a == b: return float(x >= a)
	return clamp(abs((x - a) / (b - a)),0,1)

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
		
		
		transform.origin.z = -current_dist
		visible = true
		
		if SSP.mod_chaos:
			var v = ease(max((current_offset_ms-250)/400,0),1.5)
			transform.origin.x = real_position.x + (chaos_offset.x * v)	
			transform.origin.y = real_position.y + (chaos_offset.y * v)
		
		if SSP.note_visual_approach:
			$Approach.opacity = 1 - (current_dist / SSP.spawn_distance)
			
			$Approach.scale.x = 0.4 * ((current_dist / SSP.spawn_distance) + 0.3)
			$Approach.scale.y = 0.4 * ((current_dist / SSP.spawn_distance) + 0.3)
			
			$Approach.global_translation.z = 0
		
		if fade_in_enabled or fade_out_enabled:
			var fade_in:float = 1
			var fade_out:float = 1
			
			if fade_in_enabled: 
				fade_in = linstep(fade_in_start,fade_in_end,current_dist)
			if fade_out_enabled:
				fade_out = linstep(fade_out_end,fade_out_start,current_dist)
			
			var alpha:float = min(fade_in,fade_out)
			
			$Mesh.visible = (alpha != 0)
			if mat_s and mat_t:
				mat_s.set_shader_param("fade",alpha)
				mat_t.set_shader_param("fade",alpha)
			
		
		return true
	else:
		visible = false
		return !(state == Globals.NSTATE_ACTIVE and sign(approachSpeed) == 1 and current_dist > 100)

func check(cpos:Vector3,prevpos:Vector3=Vector3.ZERO):
	if SSP.replaying and SSP.replay.sv != 1:
		return SSP.replay.should_hit(id)
	else:
		var hbs:float = SSP.note_hitbox_size/2
		if hbs == 0.57: hbs = 0.56875 # 1.1375
		var ori:Vector3 = transform.origin
		return (cpos.x <= ori.x + hbs and cpos.x >= ori.x - hbs) and (cpos.y <= ori.y + hbs and cpos.y >= ori.y - hbs)

func setup(color:Color):
	var mat2:SpatialMaterial = get_node("Spawn/Mesh").get_surface_material(0).duplicate()
	set_physics_process(false)
	mat_s = solid_mat.duplicate()
	mat_t = transparent_mat.duplicate()
	$Mesh.set_surface_material(0,mat_s)
	if $Mesh.get_surface_material_count() > 1:
		$Mesh.set_surface_material(1,mat_t)
	if $Mesh.get_surface_material_count() > 2:
		$Mesh.set_surface_material(2,mat_s)
	get_node("Spawn/Mesh").set_surface_material(0,mat2)
	mat_s.set_shader_param("notecolor",color)
	mat_t.set_shader_param("notecolor",color)
	mat2.albedo_color = color
	col = color
	
	if SSP.mod_chaos:
		var rng = get_parent().chaos_rng
		chaos_offset = Vector2(rng.randf_range(-1,1),rng.randf_range(-1,1)).normalized() * 2
		real_position = Vector2(transform.origin.x,transform.origin.y)
	
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
