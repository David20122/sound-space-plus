extends Control
class_name SettingControl

signal value_changed

@export var target:Array[String]

@export_subgroup("Signal")
@export var signal_emitter_path:NodePath
@onready var signal_emitter = get_node(signal_emitter_path)
@export var signal_name:String
@export var property_name:String

func _ready():
	call_deferred("reset",get_setting())
	signal_emitter.connect(signal_name,Callable(self,"signal_received"))

func reset(value=get_setting()):
	signal_emitter.set(property_name,value)
	value_changed.emit(value)
func signal_received(_value):
	set_setting(_value)

func get_setting():
	var pos = SoundSpacePlus.settings
	if target.size() > 1:
		for i in range(target.size()-1):
			pos = pos[target[i]]
	return pos[target.back()]
func set_setting(value):
	var pos = SoundSpacePlus.settings
	if target.size() > 1:
		for i in range(target.size()-1):
			pos = pos[target[i]]
		pos[target.back()] = value
	else:
		pos.set(target.back(),value)
	value_changed.emit(value)
	SoundSpacePlus.settings.validate_self()
	SoundSpacePlus.save_settings()
