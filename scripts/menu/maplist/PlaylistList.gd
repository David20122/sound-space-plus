extends Control
class_name PlaylistList

signal on_playlist_selected
var selected_playlist:Playlist

@onready var list:HBoxContainer = $List
@onready var origin_button:Button = $List/All

var playlists:Dictionary = {}

func _ready():
	for playlist in SoundSpacePlus.playlists.items:
		playlist_added(playlist)
	SoundSpacePlus.playlists.connect("on_item_added",Callable(self,"playlist_added"))
	SoundSpacePlus.playlists.connect("on_item_removed",Callable(self,"playlist_removed"))
	origin_button.connect("pressed",Callable(self,"all_selected"))

func playlist_added(playlist:Playlist):
	var button = origin_button.duplicate()
	button.name = playlist.name
	button.button_pressed = false
	button.tooltip_text = playlist.name
	if playlist.cover != null:
		button.get_node("Image").texture = playlist.cover
	list.add_child(button)
	$List/Edit.move_to_front()
	if playlist.broken: button.disabled = true
	else: button.connect("pressed",Callable(self,"playlist_selected").bind(playlist))
	playlists[playlist] = button
func playlist_removed(playlist:Playlist):
	playlists[playlist].queue_free()
	playlists.erase(playlist)

func playlist_selected(playlist:Playlist):
	$List/Edit/Remove.disabled = false
	for button in list.get_children():
		if not button is Button: continue
		button.button_pressed = false
	playlists.get(playlist).button_pressed = true
	selected_playlist = playlist
	on_playlist_selected.emit(selected_playlist)

func all_selected():
	$List/Edit/Remove.disabled = true
	for button in list.get_children():
		if not button is Button: continue
		button.button_pressed = false
	origin_button.button_pressed = true
	selected_playlist = null
	on_playlist_selected.emit(null,true)
