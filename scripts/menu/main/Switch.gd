extends Panel

func to_singleplayer():
	$Local.visible = true
	$Online.visible = false

func to_multiplayer():
	$Local.visible = false
	$Online.visible = true

func _ready():
	$Online/Stats/Singleplayer.pressed.connect(to_singleplayer)
	$Local/Play/Multiplayer.pressed.connect(to_multiplayer)
