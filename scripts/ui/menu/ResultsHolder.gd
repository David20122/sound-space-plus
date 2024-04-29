extends HBoxContainer

var centered:bool = false


func center():
	centered = true
	Rhythia.was_map_screen_centered = true
	$VSeparator.visible = true
	$VSeparator2.visible = true
	$"../MapRegistry".visible = false
	$"../ScrollControl".visible = false
	$"../Filters".visible = false
	
func uncenter():
	centered = false
	Rhythia.was_map_screen_centered = false
	$VSeparator.visible = false
	$VSeparator2.visible = false
	$"../MapRegistry".visible = false
	$"../ScrollControl".visible = false
	$"../Filters".visible = false

func _ready():
	centered = Rhythia.was_map_screen_centered
	if Rhythia.single_map_mode:
		center()
