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
	SSP.hit_fov_additive = preset.additive
	SSP.hit_fov_exponential = preset.exponential
	$Desc.text = "Mode: " + preset.name

func _ready():
	for i in range(presets.size()):
		get_popup().add_item(presets[i].name,i)
	get_popup().connect("id_pressed",self,"on_pressed")
	
	if not SSP.hit_fov_additive and not SSP.hit_fov_exponential:
		$Desc.text = "Mode: Normal"
	elif SSP.hit_fov_additive and not SSP.hit_fov_exponential:
		$Desc.text = "Mode: Additive"
	elif not SSP.hit_fov_additive and SSP.hit_fov_exponential:
		$Desc.text = "Mode: exponential"
	else:
		$Desc.text = "Mode: ?"
