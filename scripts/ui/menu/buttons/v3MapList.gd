extends VBoxContainer

signal search_updated

var songs:Array = Rhythia.registry_song.get_items()
var btns:Array = []

var search_text:String = ""
var author_search_text:String = ""
var difficulty_filter:Array = Rhythia.last_difficulty_filter
var show_broken_maps:bool = false
var show_online_maps:bool = true
var flip_display:bool = false
var flip_name:bool = false

var cur_map:int = 0
var page_size:int = 10

var favorite:Array = []
var easy:Array = []
var medium:Array = []
var hard:Array = []
var logic:Array = []
var amogus:Array = []
var unknown:Array = []

var disp:Array = []

var ready:bool = false

var scroll_up:bool = false
var scroll_down:bool = false
var scroll_target:int = 0
var scrolling_to:bool = false

var check_drag:bool = false
var dragged:bool = false
var drag_cur_map:int = 0
var drag_start:Vector2 = Vector2()
var drag_offset:Vector2 = Vector2()

var momentum:float = 0

var size_x:int = 0

func next_index():
	return cur_map + int(floor(((page_size + 1)/2) * 1.2))

func prev_index():
	return cur_map - int(floor(((page_size + 1)/2) * 1.2))

func is_fav(s:Song): return favorite.has(s)

func search_matches(s:Song):
	return (
		difficulty_filter.has(s.difficulty) and
		(!s.is_online or show_online_maps) and
		(!s.is_broken or show_broken_maps) and
		(search_text == "" or s.name.to_lower().find(search_text.to_lower()) != -1) and
		(author_search_text == "" or s.creator.to_lower().find(author_search_text.to_lower()) != -1)
	)

var has_been_pressed = false

func play_song():
	if !Rhythia.selected_song: return
	if has_been_pressed: return
	has_been_pressed = true
	get_viewport().get_node("Menu").black_fade_target = true
	yield(get_tree().create_timer(0.35),"timeout")
	get_tree().change_scene("res://scenes/loaders/songload.tscn")

var pt = 1
func on_pressed(i):
	if dragged:
		dragged = false
		return
	if i < 0: return
	$Press.play()
	scroll_to(i)

	var s:Song = disp[i]
	if s != Rhythia.selected_song:
		Rhythia.select_song(s)
	else:
		print(pt)
		if pt < 0.25:
			# make sure all the things are stopped
			check_drag = false
			dragged = false
			scrolling_to = false
			momentum = 0
			play_song()
	pt = 0
	get_viewport().get_node("Menu/Main/Maps/Results").visible = true
	
func switch_to_play_screen():
	size_list()
	if Rhythia.menu_target == "res://scenes/menu/menu.tscn": return
	if disp.find(Rhythia.registry_song.get_item(Rhythia.selected_song.id)) == -1:
		reset_filters()
	get_viewport().get_node("Menu/Sidebar").press(0,true)
	cur_map = disp.find(Rhythia.registry_song.get_item(Rhythia.selected_song.id))
	load_pg(true)

var was_maximized = OS.window_maximized
var was_fullscreen = OS.window_fullscreen
func _process(delta):
	pt += delta
	if OS.window_maximized != was_maximized or OS.window_fullscreen != was_fullscreen:
		was_maximized = OS.window_maximized
		was_fullscreen = OS.window_fullscreen
		handle_window_resize()

func _physics_process(delta):
	if check_drag or dragged:
		drag_offset = get_global_mouse_position()
		var diff = drag_offset - drag_start
		if abs(diff.y) > 40:
			check_drag = false
			dragged = true
			if cur_map + int(diff.y/80) < drag_cur_map:
				call_deferred("pg_down")
			elif cur_map + int(diff.y/80) > drag_cur_map:
				call_deferred("pg_up")

	# when the mouse is released, the list will scroll based on the momentum
	if momentum != 0:
		momentum = lerp(momentum, 0, 0.3)
		if abs(momentum) < 0.3:
			momentum = 0
		else:
			if momentum < 0:
				call_deferred("pg_up")
			else:
				call_deferred("pg_down")

	if scrolling_to:
		if scroll_target < cur_map:
			call_deferred("pg_up")
		elif scroll_target > cur_map:
			call_deferred("pg_down")
		else:
			scrolling_to = false
			if disp[cur_map] != Rhythia.selected_song:
				Rhythia.select_song(disp[cur_map])
	if scroll_down:
		call_deferred("pg_down")
	if scroll_up:
		call_deferred("pg_up")
	tween_length()

func check_drag_on():
	momentum = 0
	dragged = false
	check_drag = true
	drag_start = get_global_mouse_position()
	drag_offset = drag_start
	drag_cur_map = cur_map

func check_drag_off():
	check_drag = false
	dragged = false
	momentum = (drag_offset - get_global_mouse_position()).y 

func select_random():
	if disp.size() == 0: return
	cur_map = randi()%disp.size()
	load_pg(true)
	

func load_pg(select_cur:bool=false):
	size_list()
	for n in btns: n.queue_free()
	btns.clear()

	if disp.size() == 0: return
	page_size = ((get_parent().rect_size.y)/90) * 1.5
	if page_size % 2 != 0:
		page_size += 1
	#page size isnt accurate, its a ballpark
	cur_map = clamp(cur_map, 0, disp.size() - 1)
	for i in range(prev_index(), next_index() + 1):
		var btn:Panel = make_song_button(i)
		btn.rect_min_size = Vector2(350, 90)
		btns.append(btn)
		add_child(btn)
		btn.visible = true
		if i == cur_map and select_cur:
			if btn.song != Rhythia.selected_song:
				Rhythia.select_song(btn.song)
				btn.get_node("Select").pressed = true

func append_filtering_favorites(to:Array,from:Array):
	for s in from:
		if !is_fav(s) and search_matches(s):
			to.append(s)


func build_list():
	disp = []
	favorite = []
	for id in Rhythia.favorite_songs:
		var s = Rhythia.registry_song.get_item(id)
		if s and Rhythia.is_favorite(id) and search_matches(s):
			favorite.append(s)
	favorite.sort_custom(self,"sortsong")
	disp.append_array(favorite)
	if flip_display:
		append_filtering_favorites(disp,amogus)
		append_filtering_favorites(disp,logic)
		append_filtering_favorites(disp,hard)
		append_filtering_favorites(disp,medium)
		append_filtering_favorites(disp,easy)
		append_filtering_favorites(disp,unknown)
	else:
		append_filtering_favorites(disp,easy)
		append_filtering_favorites(disp,medium)
		append_filtering_favorites(disp,hard)
		append_filtering_favorites(disp,logic)
		append_filtering_favorites(disp,amogus)
		append_filtering_favorites(disp,unknown)

func reload_to_current_page(_a=null):
	scrolling_to = false
	build_list()
	load_pg()

func update_search_text(txt:String):
	search_text = txt
	if ready: reload_to_current_page()
	emit_signal("search_updated")

func update_author_search_text(txt:String):
	author_search_text = txt
	if ready: reload_to_current_page()
	emit_signal("search_updated")

func update_search_dfil(dfil:Array):
	difficulty_filter = dfil
	Rhythia.last_difficulty_filter = dfil
	if ready: reload_to_current_page()
	emit_signal("search_updated")

func update_search_showbroken(show:bool):
	show_broken_maps = show
	if ready: reload_to_current_page()

func update_search_showonline(show:bool):
	show_online_maps = show
	if ready: reload_to_current_page()

func update_search_flipped(flip:bool):
	flip_display = flip
	if ready: reload_to_current_page()

func update_search_flip_name(flip:bool):
	flip_name = flip
	easy.sort_custom(self,"sortsongsimple")
	medium.sort_custom(self,"sortsongsimple")
	hard.sort_custom(self,"sortsongsimple")
	logic.sort_custom(self,"sortsongsimple")
	amogus.sort_custom(self,"sortsongsimple")
	if ready: reload_to_current_page()

func sortab(a, b): return a < b

func sortsongsimple(a:Song, b:Song):
	if flip_name:
		if a.name != b.name: return a.name.to_lower() > b.name.to_lower()
		else: return a.id > b.id
	else:
		if a.name != b.name: return a.name.to_lower() < b.name.to_lower()
		else: return a.id < b.id

func sortsong(a:Song, b:Song):
	var ad = a.difficulty
	var bd = b.difficulty
	if ad == -1: ad = 255
	if bd == -1: bd = 255
	if ad != bd:
		if flip_display: return ad > bd
		else: return ad < bd
	else: return sortsongsimple(a,b)

func reset_filters():
	update_search_text("")
	update_author_search_text("")
	update_search_dfil([Globals.DIFF_EASY,Globals.DIFF_MEDIUM,Globals.DIFF_HARD,Globals.DIFF_LOGIC,Globals.DIFF_AMOGUS])
	update_search_showbroken(false)
	update_search_showonline(true)
	update_search_flipped(false)
	update_search_flip_name(false)

func prepare_songs():
	for i in range(songs.size()):
		var map:Song = songs[i]
		var add_to:Array
		match map.difficulty:
			Globals.DIFF_EASY: add_to = easy
			Globals.DIFF_MEDIUM: add_to = medium
			Globals.DIFF_HARD: add_to = hard
			Globals.DIFF_LOGIC: add_to = logic
			Globals.DIFF_AMOGUS: add_to = amogus
			_: add_to = unknown
		#if map not in add_to
		if add_to.find(map) == -1:
			add_to.append(map)
	easy.sort_custom(self,"sortsongsimple")
	medium.sort_custom(self,"sortsongsimple")
	hard.sort_custom(self,"sortsongsimple")
	logic.sort_custom(self,"sortsongsimple")
	amogus.sort_custom(self,"sortsongsimple")

func make_song_button(id:int=-1):
	if id < 0 or id >= disp.size():
		var btn:Panel = $EMPTY.duplicate()
		btn.rect_min_size = Vector2(int(size_x - (page_size/2) * 10), 0)
		return btn
	var map:Song = disp[id]
	if map == null: return
	var btn:Panel
	match map.difficulty:
		Globals.DIFF_EASY: btn = $EASY.duplicate()
		Globals.DIFF_MEDIUM: btn = $MEDIUM.duplicate()
		Globals.DIFF_HARD: btn = $HARD.duplicate()
		Globals.DIFF_LOGIC: btn = $LOGIC.duplicate()
		Globals.DIFF_AMOGUS: btn = $AMOGUS.duplicate()
		_: btn = $NODIF.duplicate()
	btn.rect_min_size = Vector2(size_x - 50, 0)
	btn.get_node("Label").visible = false
	if map.has_cover:
		btn.get_node("Cover").visible = true
		btn.get_node("Cover").texture = map.cover
	btn.get_node("Name").visible = true
	if map.name.length() > 80:
		btn.get_node("Name").text = strip_diactritics(map.name)
	else:
		btn.get_node("Name").text = map.name
	btn.song = map
	if map.warning != "" || map.is_broken:
		if map.is_broken: btn.get_node("Name").modulate = Color(1,0.4,0.4)
		else: btn.get_node("Name").modulate = Color(1,1,0.2)
	var rbtn:Button = btn.get_node("Select")
	if is_fav(map): btn.get_node("F").visible = true
	btn.get_node("Cloud").visible = map.is_online
	rbtn.disabled = false
	rbtn.connect("pressed",self,"on_pressed",[id])
	#set the pressed action mode to release so it doesn't trigger on mouse down
	rbtn.action_mode = 1
	rbtn.connect("button_down", self, "check_drag_on")
	rbtn.connect("button_up", self, "check_drag_off")
	rbtn.keep_pressed_outside = true
	if map == Rhythia.selected_song:
		btn.get_node("Select").pressed = true
	return btn

func pg_up():
	if cur_map < 0: return
	cur_map -= 1

	$Press.play()
	var out:Panel = btns.pop_back()
	tween_out(out) # freed in tween

	var btn:Panel = make_song_button(prev_index())
	btns.insert(0,btn) # BEFORE
	add_child(btn) 
	move_child(btn, 0) # to top
	btn.visible = true
	tween_in(btn)
	
func pg_down():
	if cur_map >= disp.size() - 1: return
	cur_map += 1
	
	$Press.play()
	var out:Panel = btns.pop_front()
	tween_out(out) # freed in tween
	var btn:Panel = make_song_button(next_index())
	btns.append(btn) # AFTER
	add_child(btn) # at end
	btn.visible = true
	tween_in(btn)

func tween_out(p:Panel):
	var tween = get_tree().create_tween()
	tween.tween_property(p, "rect_min_size", Vector2(size_x - (page_size/2) * 10, 0), 0.2)
	tween.tween_callback(p, "queue_free")

func tween_in(p:Panel):
	var tween = get_tree().create_tween()
	tween.tween_property(p, "rect_min_size", Vector2(size_x - (page_size/2) * 10, 80), 0.2)

func tween_length():
	for i in btns.size():
		var tween = get_tree().create_tween()
		tween.tween_property(btns[i], "rect_min_size", Vector2(size_x-(15*(abs((page_size/2)-i +1))), 90), 0.15)
	

func _input(ev:InputEvent):
	if is_visible_in_tree() and ev is InputEventMouseButton and ev.is_pressed():
		if ev.button_index == BUTTON_WHEEL_UP:
			scrolling_to = false
			call_deferred("pg_up")
		elif ev.button_index == BUTTON_WHEEL_DOWN:
			scrolling_to = false
			call_deferred("pg_down")

func handle_window_resize():
	if ready: reload_to_current_page()

func firstload():
#	if the button is held down, it will keep scrolling
	get_parent().get_parent().get_parent().get_node("ScrollControl/P").connect("button_down",self,"pg_down_cont")
	get_parent().get_parent().get_parent().get_node("ScrollControl/M").connect("button_down",self,"pg_up_cont")
	get_parent().get_parent().get_parent().get_node("ScrollControl/P").connect("button_up",self,"pg_down_stop")
	get_parent().get_parent().get_parent().get_node("ScrollControl/M").connect("button_up",self,"pg_up_stop")
	
	get_parent().get_parent().get_node("T/Random").connect("pressed",self,"select_random")
	prepare_songs()
	reload_to_current_page()
	ready = true
	Rhythia.connect("favorite_songs_changed",self,"reload_to_current_page")
	Rhythia.connect("download_done",self,"update_clouds")
	get_viewport().connect("size_changed",self,"handle_window_resize")
	Rhythia.emit_signal("map_list_ready")

func update_clouds():
	for btn in btns:
		if btn.has_node("Cloud") and btn.song:
			btn.get_node("Cloud").visible = btn.song.is_online

func pg_up_cont():
	scrolling_to = false
	scroll_up = true
	
func pg_up_stop():
	scroll_up = false

func pg_down_cont():
	scrolling_to = false
	scroll_down = true

func pg_down_stop():
	scroll_down = false

func scroll_to(i:int):
	if i < 0 or i >= disp.size(): return
	scroll_target = i
	scrolling_to = true

func _ready():
	randomize()
	if !visible: return
	$EASY.visible = false
	$MEDIUM.visible = false
	$HARD.visible = false
	$LOGIC.visible = false
	$AMOGUS.visible = false
	$NODIF.visible = false
	$EMPTY.visible = false

	Engine.iterations_per_second = 60
	call_deferred("firstload")
	#tryna get the screen size but uh it no change
	size_list()
	
	print("size_x: ", size_x)

func size_list():
	size_x = get_viewport_rect().size.x/2.8
	$"..".rect_min_size.x = size_x

func strip_diactritics(s:String): # we hardcoding tonight   -  edit nvm im literally a genius
#	var diacritics = "[̴̧̳̦̜̱͖̲̺͊͜1̷̨̛̝̼̓͒8̶̳̘̥̰̌̋̎͛̐͛̄̾ͅ6̶̡̛̦̻̭̅͝0̷̼̤͓̹͚͇͐͒́͗̿̍͋̕͜ ̸̦̥̻͈̳̥̲͖̆̀̽̋͘Ḇ̴̢̲̞̰͉̬͙̮̗͒̿̉͛͊P̸̩͉̻͓̱͕͖͉͕̉͌̈̅̃̈͑̚͜͝M̶̡̜͕̺̞͔̾̉ ̵̠̈È̸̛̤̖͍̈̓̏̒̆̋͘x̸̨̛͉̀͛͑͑́t̸̲̹̖̺̥̪̙͗̒̓̆̀͒͒̚r̷̲̩̦̓̔̓̑̀̿́̕͝ã̷̢̢̤̹̹̝̓͌̃͂t̸̲͉͊̀o̸͉͈̿̿̌͋̋n̶̗̺̩̱̠͚͌͛̈́͂̃̀̚͠͝ȩ̷̠̻͕̠̫̗͖̹̊]̶͖̙̳̳̲̪̌̆̄̈͊͛͘͜͜͜͝ ̸̧̩͕̲́̇̃̑A̶̱̖͔̪̦̮̐̉̀͗͊̚͝w̶̢͕̬̪̞̲͚͕̫̠̎̀̾̌̓̊̚͝͠â̵͇̮͖̜̱͙̗k̸̢̛̥̩͈̤̩͍̱͍͇̆̆̀̎̓͐̊̕ȩ̵̦̙̠̬̔̍́̚s̴̡̬̦̈́̈̄͌̃͠y̶̙͒͐̉̆̔ ̸̙̦̲̃͆̇́́͂͠C̵̨̖̻̯̪͎̀̊̄̏͛͗͝h̵̨̦̫̖͇̮̥̿͊̎̂͝r̴̖̙̤͖̤̻̝̬̗̓̄̓̆̇̈́̇̄͠ḭ̷̧̧͙̲͈̬̦̮̈́̀͗͌̕ͅs̴̯̿t̸̡̡͈̰̮͎̺͌̏ͅḿ̸̢̛̼̼͖̗ã̵̢̢̬͜s̶̡̙̼̥̣̺̻̭̱̈̈́̆̒̒̈́͠ͅ ̷̧̗͌́̐̌̽̅͠B̴̨̡̢̟͕̦̹͉̺̔ͅë̷̻̞͎̬͎̗͋̀͐́̅l̷̛̠̪͕͖̊̾l̶̹̤͊͊s̷̛͉͛͌̐͘̚̚͘ ̷͕̯̲̟̦̥͍̞͑̾̀͆͛͑̂͊͐R̵̮̮͖̥̜̠̖̥̲͇̋́i̵̟͚̭̣̙̫̙̘͍͛̍͝ͅņ̷̩͉̮̭͙̌͆g̵̨̡̹̗̗͍̟̟̩̓̾̂̍̆ ̴̺̥̙͉͉̾̉̽f̴͓̏̿̅̋͛̓̓o̴͈̎̀͒̏̚͠͝r̷̡̬͉͇̞̉̈̀ ̶̡̛̘̭̩͓̟̊̆̓̓̏̇͝͝H̴̢͓̫̰́̈̋E̶̛̛̥̬̯̺͊̏̽̀L̵̟̮̞̫̟͗̑̀͂̽͑̔̐̉̕L̷̛̹̼͎̰͗̾̆͋̊́̆͆"
#	if s.is_subsequence_ofi(diacritics):
#		return "[1860] BPM Extratone Awakesy Christmas Bells Ring for HELL"
#	return s
# ^^ this map is the only reason im doing this ^^
#	this removes all COMBINING UTF8 values to prevent spammed diactritics also known as zalgo text since it lags the maplist
#	i found those values at https://www.utf8-chartable.de/unicode-utf8-table.pl?number=1024&utf8=0x -  starts at U+0300 ends at U+036F
#	print(s)
	var pool:PoolByteArray = s.to_utf8()
#	print(pool)
	var output_bytes: Array = []
	
	# List of UTF-8 byte values to remove
	var byte_values_to_remove = [
		0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86,
		0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d,
		0x8e, 0x8f, 0x90, 0x91, 0x92, 0x93, 0x94,
		0x95, 0x96, 0x97, 0x98, 0x99, 0x9a, 0x9b,
		0x9c, 0x9d, 0x9e, 0x9f, 0xa0, 0xa1, 0xa2,
		0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9,
		0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf, 0xb0,
		0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7,
		0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe,
		0xbf, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85,
		0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c,
		0x8d, 0x8e, 0x8f, 0x90, 0x91, 0x92, 0x93,
		0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a,
		0x9b, 0x9c, 0x9d, 0x9e, 0x9f, 0xa0, 0xa1
	]
	
#	var prev_byte: int = -1
	var removed:bool = false
	for i in range(pool.size() - 1, -1, -1):
		if removed:
			removed = false
			continue
		var byte_value = pool[i]
		var prev_byte = -1
		if i != 0:
			prev_byte = pool[i - 1]
		
		if byte_value in byte_values_to_remove:
			# If the current byte his preceded by 0xcc or 0xcd, remove it and previous byte
			if prev_byte == 0xcc or prev_byte == 0xcd:
				removed = true
				continue
		output_bytes.insert(0, byte_value)
	
	return PoolByteArray(output_bytes).get_string_from_utf8()
	
