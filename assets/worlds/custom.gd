extends Spatial

var colors:Array = Rhythia.selected_colorset.colors

func hit(noteColor:Color):
	pass

func _ready():
	get_parent().get_node("Game").connect("hit",self,"hit")
