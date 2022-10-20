extends MenuButton

var presets = [
	
	# basil's modes
	{ name = "Half-lock", cam = 6.5, ui = 1.63, grid = 0, spin = false, faraway = false },
	{ name = "Full-lock", cam = 0, ui = 0, grid = 0, spin = false, faraway = false },
	{ name = "Spin", cam = 0, ui = 0, grid = 0, spin = true, faraway = false },
	{ name = "Spin (faraway hud)", cam = 0, ui = 0, grid = 0, spin = true, faraway = true },
	{ name = "Half-lock (faraway hud)", cam = 6.5, ui = 1.63, grid = 0, spin = false, faraway = true },
	
	# pyrule's modes
	{ name = "Spin-lock (mid-pivot)", cam = 0, ui = -64, grid = -32, spin = true, faraway = true },
	{ name = "Reverse-lock", cam = -6.5, ui = -1.63, grid = 0, spin = false, faraway = false },
	{ name = "Reverse-lock (faraway hud)", cam = -6.5, ui = 0, grid = 0, spin = false, faraway = true },
	
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
