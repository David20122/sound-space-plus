extends Control

func _ready():
	SoundSpacePlus.selected_mods.speed_mod = Mods.Speed.PRESET
	for i in get_child_count():
		get_child(i).get_node("CheckBox").connect("pressed",Callable(self,"preset_selected").bind(i))

func preset_selected(index:int):
	for i in get_child_count():
		get_child(i).get_node("CheckBox").button_pressed = i == index
	SoundSpacePlus.selected_mods.speed_preset = index
