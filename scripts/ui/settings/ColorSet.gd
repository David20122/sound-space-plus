extends GridContainer

onready var base = $Color

var btns = {}

func upd(_c=null):
	for k in btns.keys():
		var v = (k.id == SSP.selected_colorset.id)
		btns[k].get_node("Select").disabled = v
		if v: btns[k].self_modulate = Color(1,1,1)
		else: btns[k].self_modulate = Color(0.5,0.5,0.5)

func col(): columns = rect_size.x / 100

func _ready():
	for cs in SSP.registry_colorset.items:
		var set:ColorSet = cs
		var btn = $Color.duplicate()
		btn.get_node("Name").text = set.name
		btn.visible = true
		
		var color_count = set.real_colors.size()
		var sel = btn.get_node("Select")
		btn.get_node("Mirror").visible = set.mirror
		sel.hint_tooltip = set.name + "\nby " + set.creator
		
		var color_grid = btn.get_node("Colors")
		var col_template = btn.get_node("Colors/T")
		
		if color_count == 3: color_grid.columns = 3
		elif color_count == 0: color_grid.columns = 1
		else: color_grid.columns = ceil(sqrt(float(color_count)))
		
		for c in set.real_colors:
			var colrect = col_template.duplicate()
			colrect.color = c
			colrect.visible = true
			color_grid.call_deferred("add_child",colrect)
		
#		var even_v = fmod(color_grid.columns,2)
#		var even_h = fmod(ceil(color_count / color_grid.columns),2)
#		color_grid.set("custom_constants/vseparation",even_v+1)
#		color_grid.set("custom_constants/vseparation",even_h+1)
		
		sel.connect("pressed",SSP,"select_colorset",[cs])
		btns[cs] = btn
		call_deferred("add_child",btn)
	upd()
	SSP.connect("selected_colorset_changed",self,"upd")
	connect("resized",self,"col")
	col()
