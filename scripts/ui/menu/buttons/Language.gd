extends OptionButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var en = 1
var jp = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	add_items()

func add_items():
	drop_down_menu.add_item(tr("English")
	drop_down_menu.add_item(tr("Japanese)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
