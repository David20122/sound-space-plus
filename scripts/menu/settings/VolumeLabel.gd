extends Label

@export var label:String = "Volume"
@onready var control:SettingControl = get_parent()

func _ready():
	control.connect("value_changed",Callable(self,"value_changed"))
func value_changed(value):
	text = label + " (%s%%)" % str(value*100)
