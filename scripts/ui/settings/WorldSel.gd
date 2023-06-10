extends MenuButton

var worlds:Array = []
var current_sel:int

func on_pressed(i):
	SSP.select_world(worlds[i])

func on_world_selected(selected_world:BackgroundWorld):
	text = selected_world.name
	get_popup().set_item_checked(current_sel,false)
	for i in range(worlds.size()):
		var world:BackgroundWorld = worlds[i]
		if world == selected_world:
			current_sel = i
			
			get_popup().set_item_checked(i,true)

func _ready():
	var found:Array = SSP.registry_world.get_items()
	for i in range(found.size()):
		var world:BackgroundWorld = found[i]
		get_popup().add_check_item(world.name,i)
		worlds.append(world)
		if world == SSP.selected_space:
			current_sel = i
			get_popup().set_item_checked(i,true)
	SSP.connect("selected_space_changed",self,"on_world_selected")
	get_popup().connect("id_pressed",self,"on_pressed")
	on_world_selected(SSP.selected_space)
