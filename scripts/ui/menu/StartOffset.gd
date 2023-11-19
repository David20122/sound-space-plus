extends HSlider

func get_seconds_from_ms(ms:float):
	return max(floor(ms / 1000),0)

func value_changed(value):
	Rhythia.start_offset = value * 1000
	call_deferred("upd_label")

func on_map_selected(map):
	self.max_value = get_seconds_from_ms(Rhythia.selected_song.last_ms)

func _ready():
	connect("value_changed",self,"value_changed")
	Rhythia.connect("selected_song_changed",self,"on_map_selected")
	
	if (Rhythia.selected_song != null):	# after song pass
		on_map_selected(null)
		self.value = Rhythia.start_offset / 1000
		
func upd_label():
	var total_seconds = int(self.value)
	var minutes = floor(total_seconds / 60)
	var seconds = total_seconds % 60
	$TimeLabel.text = "%d:%02d" % [minutes,seconds]
