extends XROrigin3D

# Add this script to your XROrigin3D node and it will initialise OpenVR for you automatically.

# Our plugin will now use the first actions.json found in the following locations
# 1) in the actions folder alongside the executable
# 2) in the actions folder within your project folder (i.e. "res://actions/actions.json")
# 3) in the actions folder within the plugin (i.e. "res://addons/godot-openvr/actions/actions.json")
# OpenVR can't read actions files within the exported datapack.

# The plugin always registers atleast one action set.
# If you have renamed this action set you can specify the name here
@export (String) var default_action_set = "/actions/godot"

# If we render to a custom viewport give our node path here.
@export (NodePath) var viewport = null

# Convenience setting for setting physics update rate to a multiple of our HMDs frame rate (set to 0 to ignore)
@export var physics_factor = 2

var arvr_interface : XRInterface = null
var openvr_config = null

func get_openvr_config():
	return openvr_config

func _ready():
	# Load our config before we initialise
	openvr_config = preload("res://addons/godot-openvr/OpenVRConfig.gdns");
	if openvr_config:
		print("Setup configuration")
		openvr_config = openvr_config.new()
		
		openvr_config.default_action_set = default_action_set

	# Find the interface and initialise
	arvr_interface = XRServer.find_interface("OpenVR")
	if arvr_interface and arvr_interface.initialize():
		# We can't query our HMDs refresh rate just yet so we hardcode this to 90
		var refresh_rate = 90
		
		# check our viewport
		var vp : SubViewport = null
		if viewport:
			vp = get_node(viewport)
			if vp:
				# We copy this, while the XRServer will resize the size of the viewport automatically
				# it can't feed it back into the node. 
				vp.size = arvr_interface.get_render_target_size()
				
		
		# No viewport? get our main viewport
		if !vp:
			vp = get_viewport()
		
		# switch to ARVR mode
		vp.arvr = true
		
		# keep linear color space, not needed and thus ignored with the GLES2 renderer
		vp.keep_3d_linear = true
		
		# make sure vsync is disabled or we'll be limited to 60fps
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if (false) else DisplayServer.VSYNC_DISABLED)
		
		if physics_factor > 0:
			# Set our physics to a multiple of our refresh rate to get in sync with our rendering
			Engine.physics_ticks_per_second = refresh_rate * physics_factor

