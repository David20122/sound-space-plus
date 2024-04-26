extends HBoxContainer

var centered:bool = false


func center():
	centered = true
	Rhythia.was_map_screen_centered = true

func uncenter():
	centered = false
	Rhythia.was_map_screen_centered = false

func _ready():
	centered = Rhythia.was_map_screen_centered
