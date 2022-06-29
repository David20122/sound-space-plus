extends ColorRect
class_name ConfirmationPrompt2D

signal option_selected

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
			if option.has("wait"):
				button.text = "%s (%s)" % [option.text, ceil(option.wait)]
				button.disabled = true
			else:
				button.text = option.text
				button.disabled = false
		else:
			button.visible = false
	buttons[0].grab_focus()
	visible = true
	raise()
	is_open = true
	current_options = options

func close():
	visible = false
	is_open = false
	current_options = []

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
	for i in range(buttons.size()):
		buttons[i].connect("pressed",self,"emit_signal",["option_selected",i])
