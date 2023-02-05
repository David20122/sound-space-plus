extends ColorRect

var scroll_speed:float = 24
var _scroll_position:float = 0

func _ready():
	apply_warning(null)
	if OS.has_feature("debug"): apply_warning("DEBUG")

func apply_warning(status):
	if status == null:
		visible = false
		return
	var message = Globals.StatusMessages[status]
	color = message[0]
	$Slider/LabelA.text = message[1]
	$Slider/LabelB.text = message[1]

func _process(delta):
	_scroll_position += scroll_speed * delta
	var width = $Slider.rect_size.x / 2
	if _scroll_position >= width:
		_scroll_position -= width
	$Slider.rect_position.x = _scroll_position-width