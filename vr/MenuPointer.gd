extends Area

onready var viewport:Viewport = get_node("Viewport")
export(Vector2) var size

var last_screen_pos:Vector2 = Vector2(0,0)
var active:bool = false # Cursor is on this screen

func _input(event:InputEvent):
	if active:
		if event is InputEventKey:
			viewport.input(event)
		elif event.is_action("vr_click"):
			var ev:InputEventMouseButton = InputEventMouseButton.new()
			ev.position = last_screen_pos
			ev.button_index = BUTTON_LEFT
			ev.button_mask = BUTTON_MASK_LEFT
			ev.pressed = Input.is_action_pressed("vr_click")
			viewport.input(ev)

func _process(delta):
	active = (SSP.vr_player.primary_ray.is_colliding() and (SSP.vr_player.primary_ray.get_collider() == self))
	if active:
		# Cursor
		var p = SSP.vr_player.primary_ray.get_collision_point()
		
		var lp3 = global_transform.xform_inv(p)
		var local_pos = Vector2(lp3.x,lp3.y)
		var percent = Vector2(
			clamp((local_pos.x + (size.x/2.0)) / size.x,  0,1),
			clamp(1.0 - ((local_pos.y + (size.y/2.0)) / size.y),  0,1)
		)
		var screen_pos = Vector2(
			round(percent.x * viewport.size.x),
			round(percent.y * viewport.size.y)
		)
		
		viewport.get_node("Label").text = "r: %s\np: %s\ns: %s" % [local_pos,percent,screen_pos]
		
		if screen_pos != last_screen_pos:
			var ev:InputEventMouseMotion = InputEventMouseMotion.new()
			var relative = screen_pos - last_screen_pos
			ev.relative = relative
			ev.speed = relative / delta
			ev.pressure = Input.get_action_raw_strength("vr_click")
			ev.position = screen_pos
			ev.global_position = screen_pos
			
			viewport.input(ev)
			last_screen_pos = screen_pos
		
		$Pointer.global_transform.origin = p + Vector3(0,0,0.001)
		$PointerTrail.global_transform = $Pointer.global_transform
		$Pointer.visible = true
		$PointerTrail.emitting = SSP.cursor_trail
		$Pointer.scale = Vector3(SSP.cursor_scale,SSP.cursor_scale,SSP.cursor_scale) * 0.5
		var sc:CurveTexture = $PointerTrail.process_material.scale_curve
		sc.curve.set_point_value(0,SSP.cursor_scale * 0.5)
		
		# try to show the effects of smart trail
		var target_detail = SSP.trail_detail * (1 + float(SSP.smart_trail))
		if $PointerTrail.amount != target_detail or $PointerTrail.lifetime != SSP.trail_time:
			$PointerTrail.amount = target_detail
			$PointerTrail.lifetime = SSP.trail_time
		
		if SSP.cursor_color_type == Globals.CURSOR_RAINBOW:
			$Pointer.mesh.material.albedo_color = Color.from_hsv(SSP.rainbow_t*0.1,0.65,1)
			$PointerTrail.draw_pass_1.material.albedo_color = Color.from_hsv(SSP.rainbow_t*0.1,0.65,1)
		else:
			$Pointer.mesh.material.albedo_color = SSP.cursor_color
			$PointerTrail.draw_pass_1.material.albedo_color = SSP.cursor_color
	else:
		$Pointer.visible = false
		$PointerTrail.emitting = false
	

func _ready():
	var img = Globals.imageLoader.load_if_exists("user://cursor")
	if img: $Pointer.mesh.material.albedo_texture = img

	var img2 = Globals.imageLoader.load_if_exists("user://trail")
	if img2: $PointerTrail.draw_pass_1.material.albedo_texture = img2
	elif img: $PointerTrail.draw_pass_1.material.albedo_texture = img
