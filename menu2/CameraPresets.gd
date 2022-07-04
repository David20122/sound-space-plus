extends MenuButton

var presets = [
	{ name = "Half-lock", cam = 1, ui = 0.2, grid = 3, spin = false, faraway = false },
	{ name = "Full-lock", cam = 0, ui = 0, grid = 0, spin = false, faraway = false },
	{ name = "Spin", cam = 1, ui = 0, grid = 0, spin = false, faraway = false },
	{ name = "Spin (no parallax)", cam = 0, ui = 0, grid = 0, spin = false, faraway = false },
	{ name = "Spin (kermeet mode)", cam = 1, ui = 0, grid = 0, spin = false, faraway = true },
	{ name = "Half-lock (kermeet mode)", cam = 3, ui = 0, grid = 0, spin = false, faraway = true },
]

onready var cam = get_node("../../Parallax/Parallax")
onready var ui = get_node("../../UIParallax/UIParallax")
onready var grid = get_node("../../GridParallax/GridParallax")
onready var spin = get_node("../../Spin")
onready var faraway = get_node("../../FarawayHud")

func on_pressed(i):
	var preset = presets[i]
	cam.value = preset.cam
	ui.value = preset.ui
	grid.value = preset.grid
	spin.pressed = preset.spin
	spin._pressed()
	faraway.pressed = preset.faraway
	faraway._pressed()

func _ready():
	for i in range(presets.size()):
		get_popup().add_item(presets[i].name,i)
	get_popup().connect("id_pressed",self,"on_pressed")
