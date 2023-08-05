extends MenuButton

var presets = [
	
	{ name = "Normal",
		additive = false,
		exponential = false,
	},
	{ name = "Additive",
		additive = true,
		exponential = false,
	},
	{ name = "Exponential",
		additive = false,
		exponential = true,
	},
	
]

func on_pressed(i):
	var preset = presets[i]
	Rhythia.hit_fov_additive = preset.additive
	Rhythia.hit_fov_exponential = preset.exponential
	$Desc.text = "Mode: " + preset.name

func _ready():
	for i in range(presets.size()):
		get_popup().add_item(presets[i].name,i)
	get_popup().connect("id_pressed",self,"on_pressed")
	
	if not Rhythia.hit_fov_additive and not Rhythia.hit_fov_exponential:
		$Desc.text = "Mode: Normal"
	elif Rhythia.hit_fov_additive and not Rhythia.hit_fov_exponential:
		$Desc.text = "Mode: Additive"
	elif not Rhythia.hit_fov_additive and Rhythia.hit_fov_exponential:
		$Desc.text = "Mode: exponential"
	else:
		$Desc.text = "Mode: ?"
