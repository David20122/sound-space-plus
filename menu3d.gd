extends Spatial

onready var vp = $container/viewport
onready var dmenu = $container/viewport/Menu
onready var scr = $screen
export var follow_intensity = 0.01

var originw:Vector2 = (OS.get_screen_size(0)/2) - (OS.window_size/2)

func _ready():
	dmenu.get_node("Mouse").emitting = true
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	set_process_input(true)

#func _unhandled_input(event):
#	vp.input(event)

func _process(delta):
	var mp = dmenu.get_node("Mouse").position
	var cpos = Vector2(mp.x + originw.x, mp.y + originw.y)
	var mid_screen = vp.size / 2
	var d = cpos - mid_screen
	scr.rotation_degrees.y = d.x * follow_intensity
	scr.rotation_degrees.x = d.y * (follow_intensity * (vp.size.x / vp.size.y))
