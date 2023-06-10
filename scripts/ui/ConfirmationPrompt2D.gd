extends ColorRect
class_name ConfirmationPrompt2D

signal option_selected
signal done_opening
signal done_closing

onready var s_alert = $Alert
onready var s_next = $Next
onready var s_back = $Back

onready var title_label = $C/Main/V/Title/L
onready var body_label = $C/Main/V/Body/L
onready var buttons = [
	$"C/Main/V/Buttons/H/0",
	$"C/Main/V/Buttons/H/1",
	$"C/Main/V/Buttons/H/2",
	$"C/Main/V/Buttons/H/3",
]

var is_open:bool = false
var current_options:Array = []
var twn:Tween = Tween.new()
var transition_time:float = 0.4

func open(body:String, title:String="Confirm", options:Array=[
	{ text="Cancel" },
	{ text="OK", wait=3 }
]):
	title_label.text = title
	body_label.text = body
	for i in range(buttons.size()):
		var button:Button = buttons[i]
		if i < options.size():
			var option:Dictionary = options[i]
			button.visible = true
			button.disabled = true
			if option.has("wait"):
				button.text = "%s (%s)" % [option.text, ceil(option.wait)]
			else:
				button.text = option.text
		else:
			button.visible = false
	twn.stop_all()
	$C.rect_position = Vector2(-300,0)
	modulate = Color(1,1,1,0)
	visible = true
	raise()
	twn.interpolate_property($C,"rect_position",Vector2(-300,0),Vector2(0,0),transition_time,Tween.TRANS_SINE,Tween.EASE_OUT)
	twn.interpolate_property(self,"modulate",Color(1,1,1,0),Color(1,1,1,1),transition_time,Tween.TRANS_SINE,Tween.EASE_OUT)
	twn.start()
	yield(twn,"tween_all_completed")
	for i in range(buttons.size()):
		var button:Button = buttons[i]
		if i < options.size():
			button.disabled = options[i].has("wait")
	buttons[0].grab_focus()
	is_open = true
	current_options = options
	emit_signal("done_opening")

func close():
	twn.stop_all()
	twn.interpolate_property($C,"rect_position",Vector2(0,0),Vector2(300,0),transition_time,Tween.TRANS_SINE,Tween.EASE_IN)
	twn.interpolate_property(self,"modulate",Color(1,1,1,1),Color(1,1,1,0),transition_time,Tween.TRANS_SINE,Tween.EASE_IN)
	twn.start()
	is_open = false
	current_options = []
	for button in buttons: button.disabled = true
	yield(twn,"tween_all_completed")
	visible = false
	emit_signal("done_closing")

func _process(delta):
	if is_open:
		for i in range(current_options.size()):
			var option:Dictionary = current_options[i]
			var button:Button = buttons[i]
			if option.has("wait"):
				option.wait = max(option.wait - delta, 0)
				if option.wait == 0:
					button.disabled = false
					button.text = option.text
					option.erase("wait")
				else:
					button.text = "%s (%s)" % [option.text, ceil(option.wait)]

func _ready():
	visible = false
	add_child(twn)
	for i in range(buttons.size()):
		buttons[i].connect("pressed",self,"emit_signal",["option_selected",i])
