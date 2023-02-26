extends SettingControl

func _ready():
	super._ready()
	signal_emitter.connect("value_changed",Callable(self,"slider_signal_received"))

func signal_received(_value):
	set_setting(signal_emitter.get(property_name))
func slider_signal_received(value):
	value_changed.emit(value)
