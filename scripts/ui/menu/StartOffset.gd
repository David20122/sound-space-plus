extends HSlider

func get_seconds_from_ms(ms:float):
	return max(floor(ms / 1000),0)

func value_changed(value):
	Rhythia.start_offset = value * 1000
	call_deferred("upd_label")

func on_map_selected(map):
	self.max_value = get_seconds_from_ms(Rhythia.selected_song.last_ms)
	self.value = 0

func _ready():
	connect("value_changed",self,"value_changed")
	$TimeTextBox.connect("text_entered", self, "time_text_entered")
	Rhythia.connect("selected_song_changed",self,"on_map_selected")
	Rhythia.connect("speed_mod_changed", self, "_on_speed_mod_changed")

	if (Rhythia.selected_song != null):	# after song pass
		on_map_selected(null)
		self.value = Rhythia.start_offset / 1000

func time_text_entered(new_text):
	var time = new_text.split(':',false,1)
	var total_seconds:int

	if time.size() == 2: total_seconds = int(time[0]) * 60 + int(time[1])
	else: total_seconds = int(time[0])
	self.value = total_seconds

func upd_label():
	var total_seconds = int(self.value / Globals.speed_multi[Rhythia.mod_speed_level])
	var minutes = floor(total_seconds / 60)
	var seconds = (total_seconds % 60)
	var SongPreview = $"/root/Menu/Main/Maps/Results/Results/RS/H1/Info/Control/PreviewMusic/Song"
	if SongPreview.playing:
		SongPreview.seek(total_seconds * Globals.speed_multi[Rhythia.mod_speed_level])
	
	$TimeTextBox.text = "%d:%02d" % [minutes,seconds]

func _on_speed_mod_changed():
	upd_label()
