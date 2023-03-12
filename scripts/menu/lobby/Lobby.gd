extends Control

func _ready():
	hide_address(true)
	$Join/HideAddress.toggled.connect(hide_address)
	
	$Join/Nickname.text = Multiplayer.player_name
	$Join/Nickname.text_changed.connect(update_player_name)
	$Join/ColorPicker.color = Multiplayer.player_color
	$Join/ColorPicker.color_changed.connect(update_player_color)
	
	$Join/Buttons/Connect.pressed.connect(attempt_connect)
	$Join/Buttons/Host.pressed.connect(attempt_host)
	$Join/Buttons/Leave.pressed.connect(attempt_leave)

func hide_address(toggle:bool):
	$Join/Address.secret = toggle

func update_player_name(text:String):
	Multiplayer.player_name = text
func update_player_color(color:Color):
	Multiplayer.player_color = color

func attempt_connect():
	Multiplayer.join($Join/Address.text)
func attempt_host():
	Multiplayer.host()
func attempt_leave():
	Multiplayer.leave()

func _process(delta):
	var connected = Multiplayer.check_connected()
	
	$Join/Address.editable = !connected
	$Join/Buttons/Connect.visible = !connected
	$Join/Buttons/Host.visible = !connected
	$Join/Buttons/Leave.visible = connected
	
	$Join/Nickname.editable = !connected
	$Join/ColorPicker.disabled = connected
	
	if connected:
		$Join/Address.text = Multiplayer.server_ip
		var text = "Players:\n"
		for player in Multiplayer.lobby.players.values():
			var name = "[color=#%s]%s[/color]" % [player.color.to_html(false),player.nickname]
			if player.id == 1:
				name += " [lb][wave amp=8 freq=4] Host [/wave][rb]"
			if player.id == Multiplayer.api.get_unique_id():
				name += " [lb][wave amp=8 freq=4] You [/wave][rb]"
			text += name + "\n"
		$Players/List.text = text
		$Details.visible = true
		var has_map = Multiplayer.local_player.has_map
		if !has_map:
			$Details/CoverContainer/Cover.texture = preload("res://assets/images/ui/humor_funny.png")
			$Details/Song.text = "You do not have this map."
			$Details/Creator.text = "You do not have this map."
			$Details/Difficulty.text = Multiplayer.lobby.map_id
			$Details/Length.text = "N/A"
		else:
			var mapset = SoundSpacePlus.mapsets.get_by_id(Multiplayer.lobby.map_id)
			$Details/CoverContainer/Cover.texture = mapset.cover
			$Details/Song.text = mapset.name
			$Details/Creator.text = mapset.creator
			$Details/Difficulty.text = mapset.maps[0].name
			var song_length:String
			var length = ceili(mapset.audio.get_length())
			var minutes = floori(length / 60.0)
			var minutes_t = str(minutes)
			var seconds = floori(length % 60)
			var seconds_t = str(seconds)
			if seconds < 10:
				seconds_t = "0" + seconds_t
			song_length = "%s:%s" % [minutes_t, seconds_t]
			$Details/Length.text = song_length
	else:
		$Players/List.text = "Not connected to a server"
		$Details.visible = false
