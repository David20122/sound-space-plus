extends MenuButton

var maps:Array = []
var current_sel:int

func on_pressed(i):
	SSP.select_song(maps[i])

func on_map_selected(selected_map:Song):
#	text = "M: %s" % selected_set.name
	get_popup().set_item_checked(current_sel,false)
	for i in range(maps.size()):
		var map:Song = maps[i]
		if map == selected_map:
			current_sel = i
			get_popup().set_item_checked(i,true)

func _ready():
	return
#	var found:Array = SSP.registry_song.get_items()
#	for i in range(found.size()):
#		var map:Song = found[i]
#		get_popup().add_check_item(map.name,i)
#		maps.append(map)
#		if map == SSP.selected_song:
#			current_sel = i
#			get_popup().set_item_checked(i,true)
#	SSP.connect("selected_song_changed",self,"on_map_selected")
#	get_popup().connect("id_pressed",self,"on_pressed")
