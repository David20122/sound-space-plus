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
	var connected = Multiplayer.check_connected()
	var is_host = connected and Multiplayer.check_host()
	if connected and !is_host: return
	elif is_host:
		Multiplayer.lobby.rpc("set_mods",SoundSpacePlus.selected_mods.data)
		Multiplayer.lobby.rpc("start")
		return
	var mapset = map_details.mapset
	var map_index = map_details.map_index
	var scene = SoundSpacePlus.load_game_scene(SoundSpacePlus.GameType.SOLO,mapset,map_index)
	get_tree().change_scene_to_node(scene)

func _process(_delta):
	SoundSpacePlus.selected_mods.no_fail = $NoFail.button_pressed
	var connected = Multiplayer.check_connected()
	var is_host = connected and Multiplayer.check_host()
	if !is_host:
		play_button.disabled = connected
		if connected: play_button.tooltip_text = "Only the host can start the map"
		else: play_button.tooltip_text = ""
	else:
		var missing_map = []
		for player in Multiplayer.lobby.players.values():
			if !player.has_map:
				missing_map.append(player.nickname)
		play_button.disabled = missing_map.size() > 0
		if missing_map.size() > 0:
			var text = "These players don't have the map:"
			for player in missing_map:
				text += "\n" + player
			play_button.tooltip_text = text
		else:
			play_button.tooltip_text = ""
