extends ColorRect

var scroll_speed:float = 24
var _scroll_position:float = 0

var active_warnings = []
var active_warning = 0
var last_switch
var switch_interval = 24

func _ready():
	visible = false
	last_switch = Time.get_ticks_msec()/1000.0
	if OS.has_feature("debug"): active_warnings.append("DEBUG")
	if OS.has_feature("editor"): active_warnings.append("EDITOR")

func apply_warning(status):
	var message = Globals.StatusMessages.get(status,[Color(200.0/255.0,80.0/255.0,80.0/255.0),"This isn't supposed to be visible!"])
	var tween = create_tween()
	tween.tween_property(self,"color",message[0],1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.play()
	$Slider/LabelA.text = message[1]
	$Slider/LabelB.text = message[1]

func switch(time):
	last_switch = time
	var next = wrapi(active_warning+1,0,active_warnings.size())
	if next == active_warning: return
	active_warning = next
	apply_warning(active_warnings[active_warning])

func _process(delta):
	# Visibility
	if visible and active_warnings.size() < 1:
		$"../Main".offset_bottom = 0
		visible = false
		return
	elif !visible and active_warnings.size() > 0:
		visible = true
		$"../Main".offset_bottom = -24
		apply_warning(active_warnings[active_warning])

	# Scroll
	_scroll_position += scroll_speed * delta
	var width = $Slider.size.x / 2
	if _scroll_position >= width:
		_scroll_position -= width
	$Slider.position.x = _scroll_position-width

	# Switch
	var time = Time.get_ticks_msec()/1000.0
	if time - last_switch > switch_interval:
		switch(time)
