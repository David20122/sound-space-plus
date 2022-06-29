extends Camera

func _process(delta):
	if SSP.cam_unlock:
#		global_transform.origin = Vector3(0,0,4.6)
#		look_at(get_node("../Game/Spawn/Cursor").global_transform.origin,Vector3.UP)
		$RayCast.force_raycast_update()
		var collpoint = $RayCast.get_collision_point()
		if collpoint:
			get_parent().get_node("SpinPos").global_transform.origin = collpoint

var yaw = 0
var pitch = 0

func _input(event):
	if SSP.cam_unlock:
		if (event is InputEventMouseMotion) or (event is InputEventScreenDrag):
			yaw = fmod(yaw - event.relative.x * SSP.sensitivity * 0.2, 360)
			pitch = max(min(pitch - event.relative.y * SSP.sensitivity * 0.2, 89), -89)
			rotation = Vector3(deg2rad(pitch), deg2rad(yaw), 0)

func _ready():
	fov = ProjectSettings.get_setting("application/config/fov")
