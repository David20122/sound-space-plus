extends Control

func _ready():
	if SoundSpacePlus.selected_mods.speed_mod == Mods.Speed.PRESET:
		get_child(SoundSpacePlus.selected_mods.speed_preset).get_node("CheckBox").button_pressed = true
	else:
		$Custom/CheckBox.button_pressed = true
	$Custom/Value.value = SoundSpacePlus.selected_mods.speed_custom * 100.0
	$Custom/CheckBox.connect("pressed",Callable(self,"custom_selected"))
	for i in 7:
		get_child(i).get_node("CheckBox").connect("pressed",Callable(self,"preset_selected").bind(i))

func _process(_delta):
	SoundSpacePlus.selected_mods.speed_custom = $Custom/Value.value / 100.0

func preset_selected(index:int):
	for i in get_child_count():
		get_child(i).get_node("CheckBox").button_pressed = i == index
	$Custom/CheckBox.button_pressed = false
	SoundSpacePlus.selected_mods.speed_mod = Mods.Speed.PRESET
	SoundSpacePlus.selected_mods.speed_preset = index
func custom_selected():
	for i in 7:
		get_child(i).get_node("CheckBox").button_pressed = false
	$Custom/CheckBox.button_pressed = true
	SoundSpacePlus.selected_mods.speed_mod = Mods.Speed.CUSTOM
