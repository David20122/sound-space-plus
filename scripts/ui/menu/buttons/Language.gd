extends OptionButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var en = 1
var jp = 2	
var fr = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	add_items()	

func add_items():
	$ItemList.add_item(tr("English"))
	$ItemList.add_item(tr("Japanese"))
	$ItemList.add_item(tr("French"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
