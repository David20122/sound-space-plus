extends HSlider

func value_changed(value):
	Rhythia.mod_intensity = value
	call_deferred("upd_spin")

func on_map_selected(_m):
	self.value = Rhythia.mod_intensity

func _ready():
	connect("value_changed",self,"value_changed")
	$ModIntTextBox.connect("value_changed", self, "mod_int_finalized")
	Rhythia.connect("selected_song_changed",self,"on_map_selected")

func mod_int_finalized(new_value):
	self.value = new_value

func upd_spin():
	$ModIntTextBox.value = Rhythia.mod_intensity
