extends MenuButton

var presets = [
	
	{
		name = "Classic",
		panel_bg = Color("#9b000000"),
		panel_text = Color("#ffffff"),

		unpause_fill_color = Color("#80fff3"),
		unpause_empty_color = Color("#68ff00"),
		how_to_quit = Color("#ffdb00"),

		combo_fill_color = Color("#7bfff3"),
		combo_empty_color = Color("#b94b4b4b"),

		acc_fill_color = Color("#8cff00"),
		acc_empty_color = Color("#b08f8f8f"),

		giveup_text = Color("#ffffff"),
		giveup_fill_color = Color("#ff8f2c"),
		giveup_fill_color_end_skip = Color("#81ff75"),

		timer_text = Color("#ffffff"),
		timer_text_done = Color("#77ff77"),
		timer_text_canskip = Color("#b3ffff"),

		timer_fg = Color("#ffffff"),
		timer_bg = Color("#af8f8f8f"),
		timer_fg_done = Color("#25bf00"),
		timer_bg_done = Color("#af008f00"),
		timer_fg_canskip = Color("#b3ffff"),
		timer_bg_canskip = Color("#b0638f8f"),

		miss_flash_color = Color("#ff0000"),
		pause_used_color = Color("#ff66ff"),

		miss_text_color = Color("#ffffff"),
		pause_text_color = Color("#ffffff"),
		score_text_color = Color("#ffffff"),

		pause_ui_opacity = 0.75,

		grade_ss_saturation = 0.4,
		grade_ss_value = 1,
		grade_ss_shine = 1,

		grade_s_color = Color("#91fffa"),
		grade_s_shine = 0.5,

		grade_a_color = Color("#91ff92"),
		grade_b_color = Color("#e7ffc0"),
		grade_c_color = Color("#fcf7b3"),
		grade_d_color = Color("#fcd0b3"),
		grade_f_color = Color("#ff8282"),
	},
	{
		name = "Inverted",
		panel_bg = Color("#9bcecece"),
		panel_text = Color("#000000"),

		unpause_fill_color = Color("#fd00ff"),
		unpause_empty_color = Color("#8500ff"),
		how_to_quit = Color("#be0000"),

		combo_fill_color = Color("#ff00c5"),
		combo_empty_color = Color("#d64b4b4b"),

		acc_fill_color = Color("#8cff00"),
		acc_empty_color = Color("#b08f8f8f"),

		giveup_text = Color("#000000"),
		giveup_fill_color = Color("#ff8f2c"),
		giveup_fill_color_end_skip = Color("#81ff75"),

		timer_text = Color("#000000"),
		timer_text_done = Color("#000000"),
		timer_text_canskip = Color("#60005c"),

		timer_fg = Color("#000000"),
		timer_bg = Color("#af000000"),
		timer_fg_done = Color("#25bf00"),
		timer_bg_done = Color("#af008f00"),
		timer_fg_canskip = Color("#760070"),
		timer_bg_canskip = Color("#b02b172a"),

		miss_flash_color = Color("#ff0000"),
		pause_used_color = Color("#2600c2"),

		miss_text_color = Color("#000000"),
		pause_text_color = Color("#000000"),
		score_text_color = Color("#000000"),

		pause_ui_opacity = 0.75,

		grade_ss_saturation = 0.5,
		grade_ss_value = 0.5,
		grade_ss_shine =1,

		grade_s_color = Color("#143dff"),
		grade_s_shine = 0.5,

		grade_a_color = Color("#20c523"),
		grade_b_color = Color("#8a9530"),
		grade_c_color = Color("#ffb500"),
		grade_d_color = Color("#ff6600"),
		grade_f_color = Color("#d14747"),
	},
	
]


func _ready():
	for i in range(presets.size()):
		get_popup().add_item(presets[i].name,i)
	get_popup().connect("id_pressed",self,"on_pressed")
	for k in presets[0].keys():
		if k != "name":
			var target = get_node("../../" + k).get_child(0)
			if target.has_node("Desc"):
				var with:String
				var v = presets[0][k]
				if v is Color:
					with = v.to_html(v.a != 1)
				else:
					with = String(v)
				
				target.get_node("Desc").text = target.get_node("Desc").text.replace("##DEFAULT##", with)

func on_pressed(i):
	var preset = presets[i]
	for k in preset.keys():
		if k != "name":
			var target = get_node("../../" + k).get_child(0)
			if target is ColorPickerButton:
				target.color = preset[k]
				target.upd()
			elif target is SpinBox:
				target.value = preset[k]
				target.upd()

