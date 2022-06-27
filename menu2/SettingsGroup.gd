extends VBoxContainer

export(bool) var start_open = false

func _toggle():
	$Group.visible = $Title/C.pressed

func _ready():
	$Title/C.pressed = start_open
	$Group.visible = start_open
	$Title/C.connect("pressed",self,"_toggle")
