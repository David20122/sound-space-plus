extends Camera

var cursor_offset = Vector3(1,-1,0)
var sh:Vector2 = Vector2(-0.5,-0.5)

var phase:int = 0
func _process(delta):
	fov += (SSP.fov - fov) / SSP.hit_fov_decay
	if SSP.cam_unlock:
		var hlpower = (0.1 * SSP.parallax)
		var hlm = 0.25
		var ppos = get_node("../Game/Spawn/Cursor").transform.origin - cursor_offset
		transform.origin = Vector3(
			ppos.x*hlpower*hlm, ppos.y*hlpower*hlm, 3.5
		) + transform.basis.z / 4
		if SSP.replaying:
			look_at(
				get_node("../Game/Spawn/Cursor").global_transform.origin,
				Vector3.UP)
		else:
			$RayCast.force_raycast_update()
			var collpoint = $RayCast.get_collision_point()
			if collpoint:
				get_parent().get_node("SpinPos").global_transform.origin = collpoint
				var centeroff = collpoint + cursor_offset
				var cx = centeroff.x
				var cy = -centeroff.y
				cx = clamp(cx, (0 + sh.x), (3 + sh.x))
				cy = clamp(cy, (0 + sh.y), (3 + sh.y))
				centeroff.x = cx - cursor_offset.x
				centeroff.y = -cy - cursor_offset.y
				get_node("../Game/Spawn/Cursor").transform.origin = centeroff + cursor_offset

var yaw = 0
var pitch = 0

func _input(event):
	if SSP.cam_unlock and !SSP.replaying:
		if (event is InputEventMouseMotion) or (event is InputEventScreenDrag):
			yaw = fmod(yaw - event.relative.x * SSP.sensitivity * 0.2, 360)
			pitch = max(min(pitch - event.relative.y * SSP.sensitivity * 0.2, 89), -89)
			rotation = Vector3(deg2rad(pitch), deg2rad(yaw), 0)

func _ready():
	pass
#	fov = SSP.fov
