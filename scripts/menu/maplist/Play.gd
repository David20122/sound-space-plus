extends Control

@onready var map_details:MapDetails = $"../../../Details"

@onready var play_button:Button = $Play

var attempting:bool = false

func _ready():
	play_button.connect("pressed",Callable(self,"attempt_play"))
	$NoFail.button_pressed = SoundSpacePlus.selected_mods.no_fail

func attempt_play():
	if attempting: return
	attempting = true
	var mapset = map_details.mapset
	var map_index = map_details.map_index
	var scene = SoundSpacePlus.load_game_scene(SoundSpacePlus.GameType.SOLO,mapset,map_index)
	get_tree().change_scene_to_node(scene)

func _process(_delta):
	SoundSpacePlus.selected_mods.no_fail = $NoFail.button_pressed
