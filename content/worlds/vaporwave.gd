extends Spatial


func _ready():
	var timer: Control = get_node("/root/Song/Game/Grid/TimerVP/Control")
	var background = ColorRect.new()
	background.anchor_right = 1
	background.anchor_top = 0.3
	background.anchor_bottom = 0.95
	background.color = Color(0, 0, 0, 0.95)
	timer.add_child(background, true)
	timer.move_child(background, 0)
	var label = get_node("/root/Song/Game/Grid/TimerVP/Control/Label")
	var font = label.get("custom_fonts/font")
	font.outline_size = 6
	font.outline_color = Color(0, 0, 0, 1)
	label.set("custom_fonts/font", font)
	var songname = get_node("/root/Song/Game/Grid/TimerVP/Control/SongName")
	songname.set("custom_fonts/font", font)
	var time = get_node("/root/Song/Game/Grid/TimerVP/Control/Time")
	var bg = time.get("custom_styles/bg")
	bg.bg_color = Color(0, 0, 0, 0.69)
	time.set("custom_styles/bg", bg)
