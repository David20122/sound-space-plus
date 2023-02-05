extends Control

var page = 0
var max_page = 0

var songs = []

var cols:int = 0
var rows:int = 0

var buttons = {}
var button_size = 124
var button_scale = 1
onready var template_button = $List/Grid/Song

var should_update = true

func _ready():
	template_button.visible = false

func _notification(what):
	if what == NOTIFICATION_RESIZED: should_update = true

func _process(delta):
	if should_update: update_all(true)

func update_all(recalculate:bool=false):
	if recalculate: calculate()
	if $Search.rect_size.x < 696:
		$Search/Filter.rect_position.y = 44
	else:
		$Search/Filter.rect_position.y = 4
	update_buttons()

func calculate():
	var grid_width = $List.rect_size.x
	var grid_height = $List.rect_size.y - 56
	cols = floor((grid_width / (button_size + 4))-0.1)
	cols = max(cols,1)
	var buttons_width = (button_size + 4) * cols
	button_scale = grid_width / buttons_width
	var scaled_size = (button_size * button_scale) + 4
	rows = floor(grid_height / scaled_size)
	rows = max(rows,1)
	songs = SoundSpacePlus.songs.items
	var grid_area = cols * rows
	max_page = floor(songs.size()/grid_area)
	page = min(page,max_page)

func update_buttons():
	$List/Grid.columns = cols
	var grid_area = cols * rows
	var button_count = min(max(songs.size() - (grid_area * page),0), grid_area)
	var offset = grid_area * page
	var button_list = buttons.keys()
	if button_list.size() > button_count:
		for i in range(button_count,button_list.size()):
			buttons.erase(button_list[i])
			button_list[i].queue_free()
	var scaled_size = button_size * button_scale
	for i in range(button_count):
		var button
		if i < button_list.size():
			button = button_list[i]
		else:
			button = template_button.duplicate()
			button.visible = true
			$List/Grid.add_child(button)
		button.rect_min_size = Vector2(scaled_size,scaled_size)
		var song = songs[offset+i]
		buttons[button] = song
		button.get_node("Label").text = song.name
		var cover_exists = song.cover != null
		button.get_node("Label").visible = !cover_exists
		button.get_node("Image/Tiles").visible = !cover_exists
		button.get_node("Image/Cover").visible = cover_exists
		if cover_exists: button.get_node("Image/Cover").texture = song.cover
