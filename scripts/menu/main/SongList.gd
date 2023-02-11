extends Control

signal on_song_selected

var selected_song:Song

var page = 0
var max_page = 0

var songs = []

var cols:int = 0
var rows:int = 0

var buttons = {}
var button_size = 115
var button_scale = 1
@onready var template_button = $List/Grid/Song

func _ready():
	template_button.visible = false
	$List/Paginator/Next.connect("pressed",Callable(self,"page_up"))
	$List/Paginator/Prev.connect("pressed",Callable(self,"page_dn"))
	$List/Paginator/Begin.connect("pressed",Callable(self,"page_unskip"))
	$List/Paginator/End.connect("pressed",Callable(self,"page_skip"))
	$Search/Broken.connect("pressed",Callable(self,"update_all").bind(true))
	$Search/Filter/NA/Select.connect("pressed",Callable(self,"update_all").bind(true))
	$Search/Filter/Easy/Select.connect("pressed",Callable(self,"update_all").bind(true))
	$Search/Filter/Medium/Select.connect("pressed",Callable(self,"update_all").bind(true))
	$Search/Filter/Hard/Select.connect("pressed",Callable(self,"update_all").bind(true))
	$Search/Filter/Logic/Select.connect("pressed",Callable(self,"update_all").bind(true))
	$Search/Filter/Tasukete/Select.connect("pressed",Callable(self,"update_all").bind(true))
	$Search/Search.connect("text_changed",Callable(self,"_search_update"))
	$Search/Author.connect("text_changed",Callable(self,"_search_update"))
	call_deferred("update_all",true)
func _search_update(_text):
	update_all(true)

func _gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			page_dn()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			page_up()

func _notification(what):
	if what == NOTIFICATION_RESIZED: call_deferred("update_all",true)

func select_song(button):
	if buttons[button] == selected_song:
		emit_signal("on_song_selected",selected_song)
		return
	selected_song = buttons[button]
	if selected_song.broken:
		return
	$Preview.stream = selected_song.audio
	$Preview.play($Preview.stream.get_length()/3)
	$"../../../Sidebar/Buttons/Play".emit_signal("pressed")

func page_up():
	page += 1
	update_all(true)
func page_dn():
	page -= 1
	update_all(true)
func page_unskip():
	page = 0
	update_all(true)
func page_skip():
	calculate()
	page = max_page
	update_all(false)

func update_all(recalculate:bool=false):
	if recalculate: calculate()
	$List/Paginator/Label.text = "Page %s of %s" % [page+1,max_page+1]
	if $Search.size.x < 720:
		$Search/Filter.position.y = 44
	else:
		$Search/Filter.position.y = 4
	for button in $Search/Filter.get_children():
		if button.get_node("Select").pressed:
			button.modulate = Color.WHITE
		else:
			button.modulate = Color("#808080")
	update_buttons()

func calculate():
	var grid_width = $List.size.x
	var grid_height = $List.size.y - 56
	cols = floor((grid_width / (button_size + 4))-0.2)
	cols = max(cols,1)
	rows = ceil((grid_height / (button_size + 4))-0.2)
	rows = max(rows,1)
	var buttons_width = ((button_size + 4) * cols) - 4
	var buttons_height = ((button_size + 4) * rows) - 4
	button_scale = max(grid_width / buttons_width, grid_height / buttons_height)
	var scaled_size = (button_size * button_scale) + 4
	cols = round(grid_width / scaled_size)
	cols = max(cols,1)
	rows = floor(grid_height / scaled_size)
	rows = max(rows,1)
	songs = []
	var filter = {
		Song.Difficulty.UNKNOWN: $Search/Filter/NA/Select.button_pressed,
		Song.Difficulty.EASY: $Search/Filter/Easy/Select.button_pressed,
		Song.Difficulty.MEDIUM: $Search/Filter/Medium/Select.button_pressed,
		Song.Difficulty.HARD: $Search/Filter/Hard/Select.button_pressed,
		Song.Difficulty.LOGIC: $Search/Filter/Logic/Select.button_pressed,
		Song.Difficulty.TASUKETE: $Search/Filter/Tasukete/Select.button_pressed
	}
	for song in SoundSpacePlus.songs.items:
		if !filter[song.difficulty]:
			continue
		if song.broken and !$Search/Broken.button_pressed:
			continue
		var search = $Search/Search.text.strip_edges().to_lower()
		var author_search = $Search/Author.text.strip_edges().to_lower()
		var lower_name = song.name.to_lower()
		var lower_author = song.creator.to_lower()
		var matches = (search == "") or (search in lower_name) or lower_name.similarity(search) > 0.2
		var matches_author = (author_search == "") or (author_search in lower_author) or lower_author.similarity(author_search) > 0.2
		if !(matches and matches_author):
			continue
		songs.append(song)
	songs.sort_custom(Callable(self,"sort_maps"))
	var grid_area = cols * rows
	max_page = floor(songs.size() as float/grid_area)
	page = min(max(page,0),max_page)

func sort_maps(a,b):
	if a.difficulty == b.difficulty:
		return a.name.to_lower() < b.name.to_lower()
	return a.difficulty < b.difficulty

func update_button(button,song):
	button.get_node("Label").text = song.name
	if song.broken:
		button.get_node("Label").modulate = Color("#ff3344")
	else:
		button.get_node("Label").modulate = Color.WHITE
	var cover_exists = song.cover != null
	button.get_node("Label").visible = !cover_exists
	button.get_node("Image/Tiles").visible = !cover_exists
	button.get_node("Image/Cover").visible = cover_exists
	if cover_exists:
		button.get_node("Image").modulate = Color.WHITE
		button.get_node("Image/Cover").texture = song.cover
	else:
		button.get_node("Image").modulate = Song.DifficultyColours[song.difficulty]
	button.color = Song.DifficultyColours[song.difficulty]
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
			button.get_node("Select").connect("pressed",Callable(self,"select_song").bind(button))
			button.visible = true
			$List/Grid.add_child(button)
		$List/Grid.move_child(button,i+1)
		button.custom_minimum_size = Vector2(scaled_size,scaled_size)
		var song = songs[offset+i]
		buttons[button] = song
		update_button(button,song)
