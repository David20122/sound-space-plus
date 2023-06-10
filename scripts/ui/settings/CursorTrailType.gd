extends MenuButton

var presets = [
	
	{ name = "Normal",
		scale = true,
		opacity = true,
	},
	{ name = "Scale only",
		scale = true,
		opacity = false,
	},
	{ name = "Opacity only",
		scale = false,
		opacity = true,
	},
	
]

var current_sel:int

func on_pressed(i):
	get_popup().set_item_checked(current_sel,false)
	get_popup().set_item_checked(i,true)
	current_sel = i
	
	var preset = presets[i]
	SSP.trail_mode_scale = preset.scale
	SSP.trail_mode_opacity = preset.opacity
	text = preset.name


func _ready():
	if SSP.trail_mode_scale and SSP.trail_mode_opacity:
		current_sel = 0
	elif SSP.trail_mode_scale and not SSP.trail_mode_opacity:
		current_sel = 1
	elif not SSP.trail_mode_scale and SSP.trail_mode_opacity:
		current_sel = 2
	else:
		text = "Unknown"
	
	for i in range(presets.size()):
		get_popup().add_check_item(presets[i].name,i)
		if current_sel == i:
			get_popup().set_item_checked(i,true)
			text = presets[i].name
	get_popup().connect("id_pressed",self,"on_pressed")
