extends MenuButton

var sets:Array = []
var current_sel:int

func on_pressed(i):
	SSP.select_colorset(sets[i])

func on_set_selected(selected_set:ColorSet):
	text = selected_set.name
	get_popup().set_item_checked(current_sel,false)
	for i in range(sets.size()):
		var set:ColorSet = sets[i]
		if set == selected_set:
			current_sel = i
			for ii in range($Colors.get_child_count()):
				var n = $Colors.get_child(ii)
				if ii < set.colors.size():
					n.visible = true
					n.color = set.colors[ii]
				else: n.visible = false
			
			get_popup().set_item_checked(i,true)

func _ready():
	var found:Array = SSP.registry_colorset.get_items()
	for i in range(found.size()):
		var set:ColorSet = found[i]
		get_popup().add_check_item(set.name,i)
		sets.append(set)
		if set == SSP.selected_colorset:
			current_sel = i
			get_popup().set_item_checked(i,true)
	SSP.connect("selected_colorset_changed",self,"on_set_selected")
	get_popup().connect("id_pressed",self,"on_pressed")
	on_set_selected(SSP.selected_colorset)
