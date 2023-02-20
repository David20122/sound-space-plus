extends Button
class_name MapsetButton

var mapset:Mapset

func update(pressed:bool=false):
	button_pressed = pressed
	name = mapset.id
	$Song.text = mapset.name
	$Creator.text = mapset.creator
	if mapset.cover != null: $Cover.texture = mapset.cover
	if mapset.broken: disabled = true
