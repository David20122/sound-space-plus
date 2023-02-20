extends Control
class_name MapList

signal on_mapset_selected
var selected_mapset:Mapset

@onready var list_contents:VBoxContainer = $Maps/List/Contents
@onready var origin_button:Button = $Maps/List/Contents/Mapset

var buttons = []

func _ready():
	origin_button.visible = false
	call_deferred("update_list")

func update_list():
	for button in buttons:
		button.queue_free()
	buttons = []
	for mapset in SoundSpacePlus.mapsets.items:
		mapset = mapset as Mapset
		var button = origin_button.duplicate()
		button.connect("pressed",Callable(self,"mapset_button_pressed").bind(button))
		button.visible = true
		button.mapset = mapset
		button.update()
		list_contents.add_child(button)
		buttons.append(button)

func mapset_button_pressed(button:MapsetButton):
	button.update(true)
	if selected_mapset == button.mapset: return
	selected_mapset = button.mapset
	on_mapset_selected.emit(selected_mapset)
	for btn in buttons:
		if btn == button: continue
		btn.update()
