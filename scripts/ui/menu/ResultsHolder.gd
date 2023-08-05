extends HBoxContainer

var centered:bool = false

func upd():
	if centered:
		$CenterPush.visible = false
		$LeftPush/CenterContainer/Button.visible = false
	else:
		$CenterPush.visible = false
		$LeftPush/CenterContainer/Button.visible = true

func center():
	centered = true
	Rhythia.was_map_screen_centered = true
	upd()

func uncenter():
	centered = false
	Rhythia.was_map_screen_centered = false
	upd()


func _ready():
	centered = Rhythia.was_map_screen_centered
	upd()
	$CenterPush/Button.connect("pressed",self,"uncenter")
	$LeftPush/CenterContainer/Button.connect("pressed",self,"center")
