extends Spatial

var active:bool = false

var thread:Thread
var target:String = SSP.menu_target
var leaving:bool = false

func stage(text:String,done:bool=false):
	$Label2.text = text
	if done:
#		black_fade_target = true
		$Label2.text = "Loading menu"
		var res = RQueue.queue_resource(target)
		if res != OK:
			SSP.errorstr = "queue_resource returned %s" % res
			get_tree().change_scene("res://errors/menuload.tscn")
#		leaving = true


func activate():
	get_node("../Music").change(true,false,false,false)
	SSP.is_init = false
	
	thread = Thread.new()
	active = true
	
#	init vr (disabled currently)
#	var VR = ARVRServer.find_interface("OpenVR")
#	if VR and VR.initialize():
#		target = "res://vrmenudemo.tscn"
	
#	VisualServer.set_debug_generate_wireframes(true)
#	get_viewport().debug_draw = get_viewport().DEBUG_DRAW_OVERDRAW

	SSP.connect("init_stage_reached",self,"stage")
	SSP.connect("init_stage_num",self,"set_logo_target")
	var s = Globals.error_sound
#	var st = SSP.get_stream_with_default("user://loadingmusic",s)
#	if st != s:
#		$Music.stream = st
#		$Music.play()
	OS.request_permissions()
	yield(get_tree().create_timer(0.5),"timeout")
	if ProjectSettings.get_setting("application/config/auto_maximize") and SSP.auto_maximize: OS.window_maximized = true
	yield(get_tree().create_timer(0.5),"timeout")
	
	
	thread.start(SSP,"do_init")
	
	if ProjectSettings.get_setting("application/config/discord_rpc"):
		var activity = Discord.Activity.new()
		activity.set_type(Discord.ActivityType.Playing)
		activity.set_details("Initialization")
		
		if SSP.do_archive_convert: activity.set_state("Mass-converting songs")
		elif SSP.first_init_done: activity.set_state("Reloading content")
		else: activity.set_state("Starting the game")

		var assets = activity.get_assets()
		assets.set_large_image("icon")
		
		Discord.activity_manager.update_activity(activity)

func _exit_tree():
	if thread: thread.wait_to_finish()

var result

var logo_target = -2

func set_logo_target(i):
	logo_target = i

onready var logo = [
	$Logo/IconOnly,
	$Logo/S0,
	$Logo/S1,
	$Logo/S2,
	$Logo/S3,
	$Logo/S4,
]

func _process(delta):
	var total = 0
	for i in range(logo.size()):
		var n:Sprite3D = logo[i]
		i -= 1
		if i == logo_target:
			n.opacity = min(n.opacity + (delta / 0.6), 1)
		else:
			n.opacity = max(n.opacity - (delta / 0.6), 0)
		total += n.opacity
	
	if !leaving:
		if RQueue.is_ready(target):
			result = RQueue.get_resource(target)
			leaving = true
			get_node("../Music").change(false,false,false,false)
			get_parent().black_fade_target = true
			if !(result is Object):
				SSP.errorstr = "get_resource returned non-object (probably null)"
				get_tree().change_scene("res://errors/menuload.tscn")
	
	if leaving and result and get_parent().black_fade == 1 and get_node("../Music").hv == 0:
		get_tree().change_scene_to(result)
