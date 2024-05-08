extends Camera

var cursor_offset = Vector3(1,-1,0)
var replay_offset = Vector3(1,-1,0)
var sh:Vector2 = Vector2(-0.5,-0.5)
var edgec:float = 0.13125

onready var cursor = get_node("../Game/Spawn/Cursor")

var phase:int = 0

func _physics_process(delta):
	if Rhythia.hit_fov_decay != 0:
		fov += (Rhythia.get("fov") - fov) / Rhythia.hit_fov_decay

func _process(delta):
	if Rhythia.get("cam_unlock"):
		var hlpower = (0.1 * Rhythia.get("parallax"))
		var hlm = 0.25
		var ppos = cursor.transform.origin - cursor_offset
		if Rhythia.replaying:
			var replay_pos = Rhythia.replay.get_cursor_position(get_node("../Game/Spawn").rms)
			if Rhythia.replay.sv < 3: ppos = Vector3(replay_pos.x,replay_pos.y,0) - replay_offset
			else: ppos = Vector3(replay_pos.x,-replay_pos.y,0) - cursor_offset
			look_at(ppos, Vector3.UP)
			transform.origin = Vector3(
				ppos.x*hlpower*hlm, ppos.y*hlpower*hlm, 3.5
			) + transform.basis.z / 4
		elif !Rhythia.absolute_mode:
			transform.origin = Vector3(
				ppos.x*hlpower*hlm, ppos.y*hlpower*hlm, 3.5
			) + transform.basis.z / 4
			$RayCast.force_raycast_update()
			var collpoint = $RayCast.get_collision_point()
			if collpoint:
				get_parent().get_node("SpinPos").global_transform.origin = collpoint
				var centeroff = collpoint + cursor_offset
				var cx = centeroff.x
				var cy = -centeroff.y
				cursor.rpos = Vector2(cx,cy)
				if Rhythia.mod_hardrock:
					var hard_cock = edgec - 0.6
					cx = clamp(cx, (0 + sh.x + hard_cock), (3 + sh.x - hard_cock))
					cy = clamp(cy, (0 + sh.y + hard_cock), (3 + sh.y - hard_cock))
				else:
					cx = clamp(cx, (0 + sh.x + edgec), (3 + sh.x - edgec))
					cy = clamp(cy, (0 + sh.y + edgec), (3 + sh.y - edgec))
				centeroff.x = cx - cursor_offset.x
				centeroff.y = -cy - cursor_offset.y
				cursor.transform.origin = centeroff + cursor_offset
		else:
			var abs_pos = cursor.get_absolute_position()
			cursor.move_cursor_abs(abs_pos)
			abs_pos = Vector3(abs_pos.x, -abs_pos.y, 0) - cursor_offset
			transform.origin = Vector3(
				abs_pos.x*hlpower*hlm, abs_pos.y*hlpower*hlm, 3.5
			)
			look_at(abs_pos, Vector3.UP)
			transform.origin += transform.basis.z / 4

var yaw = 0
var pitch = 0

func _input(event):
	if Rhythia.get("cam_unlock") and !Rhythia.replaying and !Rhythia.absolute_mode:
		if (event is InputEventMouseMotion) or (event is InputEventScreenDrag):
			yaw = fmod(yaw - event.relative.x * Rhythia.sensitivity * 0.2, 360)
			pitch = max(min(pitch - event.relative.y * Rhythia.sensitivity * 0.2, 89), -89)
			rotation = Vector3(deg2rad(pitch), deg2rad(yaw), 0)

func _ready():
	pass
#	fov = Rhythia.get("fov")
