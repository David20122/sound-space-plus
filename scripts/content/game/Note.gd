extends Spatial
class_name Note

var grid_pushback: float = 0.1
var pushback_defaults: Dictionary = {
	"do_pushback": 4,
	"never": 0.1
}

export(ShaderMaterial) var solid_mat
export(ShaderMaterial) var transparent_mat

var notems: float
var was_visible: bool = false
var id: int = -1
var state: int = 0
var spawn_effect_t: float = 0
onready var speed_multi: float = get_parent().speed_multi
var col: Color

var chaos_offset: Vector2 = Vector2()
var chaos_rng2: RandomNumberGenerator = RandomNumberGenerator.new()
var earthquake_offset: Vector2 = Vector2()
var real_position: Vector2 = Vector2()

var fade_in_enabled: bool = true
var fade_in_start: float = 8
var fade_in_end: float = 6

var fade_out_enabled: bool = false
var fade_out_start: float = 3
var fade_out_end: float = 1

var mat_s: ShaderMaterial
var mat_t: ShaderMaterial

func linstep(a: float, b: float, x: float) -> float:
	return clamp((x - a) / (b - a), 0, 1) if a != b else float(x >= a)

func reposition(ms: float, approachSpeed: float) -> bool:
	approachSpeed /= speed_multi
	var current_offset_ms = notems - ms
	var current_dist = approachSpeed * current_offset_ms / 1000
	var spawn_distance = Rhythia.get("spawn_distance")

	if (state == Globals.NSTATE_ACTIVE and (
		(current_dist <= spawn_distance and current_dist >= -grid_pushback and sign(approachSpeed) == 1) or
		(current_dist >= -50 and current_dist <= 0.1 and sign(approachSpeed) == -1) or
		sign(approachSpeed) == 0)):
		
		if not was_visible:
			was_visible = true
			if Rhythia.note_spawn_effect:
				spawn_effect_t = 1 if not Rhythia.mod_nearsighted else spawn_effect_t
		
		transform.origin.z = -current_dist
		visible = true
		
		if Rhythia.mod_chaos:
			var v = ease(max((current_offset_ms - 250) / 400, 0), 1.5)
			transform.origin.x = real_position.x + (chaos_offset.x * v)
			transform.origin.y = real_position.y + (chaos_offset.y * v)
		
		if Rhythia.mod_earthquake:
			var rcoord = Vector2(chaos_rng2.randf_range(-0.25, 0.25), chaos_rng2.randf_range(-0.25, 0.25))
			transform.origin.x = real_position.x + (rcoord.x * (current_dist * 0.1))
			transform.origin.y = real_position.y + (rcoord.y * (current_dist * 0.1))
		
		if Rhythia.mod_hardrock:
			transform.origin.x = real_position.x * 1.5
			transform.origin.y = real_position.y * 1.5

		if Rhythia.note_visual_approach:
			var approach_scale = 0.4 * ((current_dist / spawn_distance) + 0.6)
			$Approach.opacity = 1 - (current_dist / spawn_distance)
			$Approach.scale = Vector2(approach_scale, approach_scale)
			if not Rhythia.visual_approach_follow:
				$Approach.global_translation.z = 0
				
		# note spin; not doing this all in a single Vector3 because we're trying to rotate locally
		rotate(Vector3(1, 0, 0), Rhythia.note_spin_x / 2000)
		rotate(Vector3(0, 1, 0), Rhythia.note_spin_y / 2000)
		rotate(Vector3(0, 0, 1), Rhythia.note_spin_z / 2000)
		
		if fade_in_enabled or fade_out_enabled:
			var fade_in = linstep(fade_in_start, fade_in_end, current_dist) if fade_in_enabled else 1
			var fade_out = linstep(fade_out_end, fade_out_start, current_dist) if fade_out_enabled else 1
			var alpha = min(fade_in, fade_out)
			
			$Mesh.visible = alpha != 0
			if mat_s and mat_t:
				mat_s.set_shader_param("fade", alpha)
				mat_t.set_shader_param("fade", alpha)
		
		return true
	else:
#		if Rhythia.play_hit_snd and Rhythia.ensure_hitsync: 
#			if Rhythia.sfx_2d:
#				$"../Hit2D".play()
#			else:
#				$"../Hit".transform = transform
#				$"../Hit".play()
		visible = false
		return not (state == Globals.NSTATE_ACTIVE and sign(approachSpeed) == 1 and current_dist > 100)

func check(cpos: Vector3, prevpos: Vector3 = Vector3.ZERO) -> bool:
	if Rhythia.replaying and Rhythia.replay.sv != 1:
		return Rhythia.replay.should_hit(id)
	else:
		var hbs = Rhythia.note_hitbox_size / 2
		if hbs == 0.57:
			hbs = 0.56875
		var ori = transform.origin
		return abs(cpos.x - ori.x) <= hbs and abs(cpos.y - ori.y) <= hbs

func setup(color: Color) -> void:
	var tcol = Color(color.r, color.g, color.b, Rhythia.note_opacity)
	var mat2: SpatialMaterial = get_node("Spawn/Mesh").get_surface_material(0).duplicate()
	set_physics_process(false)
	mat_s = solid_mat.duplicate()
	mat_t = transparent_mat.duplicate()
	$Mesh.set_surface_material(0, mat_s)
	if $Mesh.get_surface_material_count() > 1:
		$Mesh.set_surface_material(1, mat_t)
	if $Mesh.get_surface_material_count() > 2:
		$Mesh.set_surface_material(2, mat_s)
	get_node("Spawn/Mesh").set_surface_material(0, mat2)
	mat_s.set_shader_param("notecolor", tcol)
	mat_t.set_shader_param("notecolor", tcol)
	mat2.albedo_color = tcol
	col = tcol
	
	if Rhythia.mod_chaos:
		var rng = get_parent().chaos_rng
		chaos_offset = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)).normalized() * 2
		real_position = Vector2(transform.origin.x, transform.origin.y)
	
	if Rhythia.mod_earthquake:
		var rng = get_parent().earthquake_rng
		earthquake_offset = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)).normalized() * 2
		real_position = Vector2(transform.origin.x, transform.origin.y)
	
	if Rhythia.mod_ghost:
		fade_out_enabled = true
		fade_out_start = 18.0 / 50 * Rhythia.get("approach_rate")
		fade_out_end = 6.0 / 50 * Rhythia.get("approach_rate")
	
	if Rhythia.mod_nearsighted:
		fade_in_enabled = true
		fade_in_start = 30.0 / 50 * Rhythia.get("approach_rate")
		fade_in_end = 5.0 / 50 * Rhythia.get("approach_rate")
	else:
		fade_in_enabled = Rhythia.get("fade_length") != 0
		if fade_in_enabled:
			fade_in_start = Rhythia.get("spawn_distance")
			fade_in_end = fade_in_start * (1.0 - Rhythia.get("fade_length"))

func _ready() -> void:
	if not Rhythia.note_visual_approach and has_node("Approach"):
		$Approach.queue_free()
	grid_pushback = pushback_defaults.get("do_pushback", pushback_defaults["never"]) if Rhythia.do_note_pushback else pushback_defaults["never"]

func _process(delta: float) -> void:
	if visible:
		spawn_effect_t = max(0, spawn_effect_t - (4 * delta))
		$Spawn.scale = Vector3(1 * spawn_effect_t, 0.9 + (0.1 * spawn_effect_t), 1)
		$Spawn.visible = spawn_effect_t != 0
