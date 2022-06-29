extends MenuButton

var effects:Array = []
var current_sel:int

func on_pressed(i):
	SSP.select_hit_effect(effects[i])

func on_effect_selected(selected_effect:NoteEffect):
	text = selected_effect.name
	get_popup().set_item_checked(current_sel,false)
	for i in range(effects.size()):
		var effect:NoteEffect = effects[i]
		if effect == selected_effect:
			current_sel = i
			
			get_popup().set_item_checked(i,true)

func _ready():
	var found:Array = SSP.registry_effect.get_items()
	for i in range(found.size()):
		var effect:NoteEffect = found[i]
		get_popup().add_check_item(effect.name,i)
		effects.append(effect)
		if effect == SSP.selected_hit_effect:
			current_sel = i
			get_popup().set_item_checked(i,true)
	SSP.connect("selected_hit_effect_changed",self,"on_effect_selected")
	get_popup().connect("id_pressed",self,"on_pressed")
	on_effect_selected(SSP.selected_hit_effect)
