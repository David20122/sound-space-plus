extends Camera

var phase:int = 0
func _process(delta):
	fov += (SSP.fov - fov) / SSP.hit_fov_decay
	if SSP.cam_unlock:
		if SSP.replaying:
			look_at(
				get_node("../Game/Spawn/Cursor").global_transform.origin,
				Vector3.UP)
		else:
			$RayCast.force_raycast_update()
			var collpoint = $RayCast.get_collision_point()
			if collpoint:
				get_parent().get_node("SpinPos").global_transform.origin = collpoint

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
