extends Node2D

export(Font) var font

func _draw():
	if position.length() > 500: draw_line(-position,Vector2(0,0),Color(1,0,0),2,true)
#	draw_line(Vector2(-100,0),Vector2(100,0),Color(0,1,0),2,true)
#	draw_line(Vector2(0,-100),Vector2(0,100),Color(0,0,1),2,true)

func _process(delta):
	update()


func _ready():
	var img = Globals.imageLoader.load_if_exists("user://cursor")
	if img: $TextureRect.texture = img
