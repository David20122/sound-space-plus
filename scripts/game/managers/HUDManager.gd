extends BaseManager
class_name HUDManager

@export_node_path("Node3D") var hud_path
@onready var hud:Node3D = get_node(hud_path)

@onready var right:RightHUD = hud.get_node("RightViewport/Control")
@onready var left:LeftHUD = hud.get_node("LeftViewport/Control")
@onready var energy:EnergyHUD = hud.get_node("EnergyViewport/Control")

static func comma_sep(n: int):
	var string = str(n)
	var mod = string.length() % 3
	var result = ""
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod: result += ","
		result += string[i]
	return result

func _ready():
	right.manager = self
	left.manager = self
	energy.manager = self

func _process(_delta):
	right.score = game.player.score
	left.score = game.player.score
	energy.health = game.player.health
