extends MenuButton

var presets = [
	
	{ name = "Both",
		scale = true,
		opacity = true,
	},
	{ name = "Scale",
		scale = true,
		opacity = false,
	},
	{ name = "Opacity",
		scale = false,
		opacity = true,
	},
	
]

func on_pressed(i):
	var preset = presets[i]
	SSP.trail_mode_scale = preset.scale
	SSP.trail_mode_opacity = preset.opacity
	$Desc.text = "Mode: " + preset.name

func _ready():
	for i in range(presets.size()):
		get_popup().add_item(presets[i].name,i)
	get_popup().connect("id_pressed",self,"on_pressed")
	
	if SSP.trail_mode_scale and SSP.trail_mode_opacity:
		$Desc.text = "Mode: Both"
	elif SSP.trail_mode_scale and not SSP.trail_mode_opacity:
		$Desc.text = "Mode: Scale"
	elif not SSP.trail_mode_scale and SSP.trail_mode_opacity:
		$Desc.text = "Mode: Opacity"
	else:
		$Desc.text = "Mode: ?"
