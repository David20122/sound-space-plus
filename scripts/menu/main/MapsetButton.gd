extends Button
class_name MapsetButton

var mapset:Mapset

func update(pressed:bool=false):
	button_pressed = pressed
	name = mapset.id
	$Song.text = mapset.name
	$Creator.text = mapset.creator
	var song_length:String
	if mapset.broken or mapset.audio == null:
		song_length = "N/A"
	else:
		var length = ceili(mapset.audio.get_length())
		var minutes = floori(length / 60)
		var minutes_t = str(minutes)
		var seconds = floori(length % 60)
		var seconds_t = str(seconds)
		if seconds < 10:
			seconds_t = "0" + seconds_t
		song_length = "%s:%s" % [minutes_t, seconds_t]
	$Length.text = song_length
	if mapset.cover == null:
		$Cover.visible = false
	else:
		$Cover.visible = true
		$Cover.texture = mapset.cover
	if mapset.broken: disabled = true

var pressed_colour:Color = Color8(255,255,255,255)
var unpressed_colour:Color = Color8(200,200,200,200)
func _process(_delta):
	if button_pressed:
		$Cover.self_modulate = pressed_colour
	else:
		$Cover.self_modulate = unpressed_colour
