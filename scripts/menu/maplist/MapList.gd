extends Control
class_name MapList

signal on_mapset_selected
var selected_mapset:Mapset

@export_node_path("Control") var playlists_path
@onready var playlists:PlaylistList = get_node(playlists_path)

@onready var list:ScrollContainer = $Maps/List
@onready var list_contents:VBoxContainer = $Maps/List/Contents
@onready var top_separator:HSeparator = $Maps/List/Contents/TopSeparator
@onready var btm_separator:HSeparator = $Maps/List/Contents/BottomSeparator
@onready var origin_button:Button = $Maps/List/Contents/Mapset

@onready var origin_list:Array = SoundSpacePlus.mapsets.items
var listed_items:Array

var buttons = {}

func _ready():
	origin_button.visible = false
	call_deferred("update_items")
	call_deferred("update_list")
	playlists.connect("on_playlist_selected",Callable(self,"playlist_selected"))

func playlist_selected(playlist:Playlist=null,all:bool=false):
	if all or !playlist:
		origin_list = SoundSpacePlus.mapsets.items
	else:
		playlist.load_mapsets()
		origin_list = playlist.mapsets
	list.scroll_vertical = 0
	call_deferred("update_items")
	call_deferred("update_list")

var _last_scroll:int = 0
func _process(_delta):
	if list.scroll_vertical != _last_scroll:
		_last_scroll = list.scroll_vertical
		update_list()
func _notification(what):
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		call_deferred("update_list")

func update_items():
	listed_items = origin_list.filter(Callable(self,"filter_maps"))
	listed_items.sort_custom(Callable(self,"sort_maps"))
func filter_maps(_set:Mapset):
	return true
func sort_maps(a:Mapset,b:Mapset):
	return a.name.naturalnocasecmp_to(b.name) < 0

func update_list():
	var offset = max(0,floori(list.scroll_vertical/76.0))
	var no_items = ceili(list.size.y/76) + 1
	var end = min(listed_items.size(),offset+no_items)
	var visible_items = listed_items.slice(offset,end)
	top_separator.add_theme_constant_override("separation",(offset*76)-4)
	btm_separator.add_theme_constant_override("separation",((listed_items.size()-end)*76)-4)
	var buttons_keys = buttons.keys()
	var buttons_values = buttons.values()
	for i in range(buttons_values.size()):
		var button = buttons_values[i]
		if visible_items.has(button.mapset):
			continue
		button.queue_free()
		buttons.erase(buttons_keys[i])
	var i = 0
	for mapset in visible_items:
		i += 1
		mapset = mapset as Mapset
		if buttons.keys().has(mapset):
			list_contents.move_child(buttons[mapset],i)
			continue
		var button = origin_button.duplicate()
		button.connect("pressed",Callable(self,"mapset_button_pressed").bind(button))
		button.visible = true
		button.mapset = mapset
		button.update(selected_mapset == mapset)
		list_contents.add_child(button)
		list_contents.move_child(button,i)
		buttons[mapset] = button

func mapset_button_pressed(button:MapsetButton):
	if selected_mapset == button.mapset: return
	selected_mapset = button.mapset
	on_mapset_selected.emit(selected_mapset)
	if Multiplayer.check_connected() and Multiplayer.check_host():
		Multiplayer.lobby.map_id = selected_mapset.id
	for btn in buttons.values():
		if btn == button: continue
		btn.update()
