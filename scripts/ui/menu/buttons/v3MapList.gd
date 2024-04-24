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

func next_index():
	return cur_map + floor(((page_size + 1)/2) * 1.2)

func prev_index():
	return cur_map - floor(((page_size + 1)/2) * 1.2)

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
	$Press.play()
	var s:Song = disp[i]
	if s != Rhythia.selected_song:
		Rhythia.select_song(s)
	else:
		print(pt)
		if pt < 0.25:
			play_song()
	pt = 0
	switch_to_play_screen()

var auto_switch_to_play:bool = true
func switch_to_play_screen():
	if !auto_switch_to_play: return
	if Rhythia.menu_target == "res://scenes/menu/menu.tscn": return
	get_viewport().get_node("Menu/Main/MapRegistry").visible = false
	get_viewport().get_node("Menu/Main/Results").visible = true
	get_viewport().get_node("Menu/Sidebar/L/Results").pressed = true

var was_maximized = OS.window_maximized
var was_fullscreen = OS.window_fullscreen
func _process(delta):
	pt += delta
	if OS.window_maximized != was_maximized or OS.window_fullscreen != was_fullscreen:
		was_maximized = OS.window_maximized
		was_fullscreen = OS.window_fullscreen
		handle_window_resize()

func _physics_process(delta):
	if scroll_down:
		call_deferred("pg_down")
	if scroll_up:
		call_deferred("pg_up")

func select_random():
	if disp.size() == 0: return
	on_pressed(randi()%disp.size())
	for b in btns:
		if b.song == Rhythia.selected_song: b.get_node("Select").pressed = true
		else: b.get_node("Select").pressed = false
	switch_to_play_screen()

func load_pg(is_resize:bool=false):
	for n in btns: n.queue_free()
	btns.clear()

	if disp.size() == 0: return
	page_size = ((get_parent().rect_size.y)/80) * 1.2
	if page_size % 2 != 0:
		page_size += 1
	print("page_size: ", page_size)
	cur_map = clamp(cur_map, 0, disp.size() - 1)
	print ("cur_map: ", cur_map, " ", disp[cur_map].name)
	print ("next_index: ", next_index())
	print ("prev_index: ", prev_index())
	for i in range(prev_index(), next_index() + 1):
		var btn:Panel = make_song_button(i)
		btns.append(btn)
		add_child(btn)
		btn.visible = true
	get_parent().get_node("P").rect_position.x = rect_position.x + rect_size.x + 25
	tween_length()
#	get_parent().get_node("P").rect_size.y = ((spp/col)*132)+12
#	get_parent().get_node("M").rect_size.y = ((spp/col)*132)+12

func append_filtering_favorites(to:Array,from:Array):
	for s in from:
		if search_matches(s) and !is_fav(s):
			to.append(s)


func build_list():
	disp = []
	favorite = []
	for id in Rhythia.favorite_songs:
		var s = Rhythia.registry_song.get_item(id)
		if s and search_matches(s) and Rhythia.is_favorite(id):
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
	build_list()
	if ready: Rhythia.last_page_num = cur_map
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
#	Rhythia.connect("selected_song_changed",self,"on_map_selected")
	easy.sort_custom(self,"sortsongsimple")
	medium.sort_custom(self,"sortsongsimple")
	hard.sort_custom(self,"sortsongsimple")
	logic.sort_custom(self,"sortsongsimple")
	amogus.sort_custom(self,"sortsongsimple")

func make_song_button(id:int=-1):
	if id < 0 or id >= disp.size():
		var btn:Panel = $EMPTY.duplicate()
		btn.rect_min_size = Vector2(50, 0)
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
	btn.rect_min_size = Vector2(50, 0)
	btn.get_node("Label").visible = false
	if map.has_cover:
		btn.get_node("Cover").visible = true
		btn.get_node("Cover").texture = map.cover
	btn.get_node("Name").visible = true
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
	if map == Rhythia.selected_song:
		btn.get_node("Select").pressed = true
	return btn

func pg_up():
	if cur_map < 0: return
	cur_map -= 1
	Rhythia.last_page_num = cur_map

	$Press.play()
	var out:Panel = btns.pop_back()
	tween_out(out) # freed in tween

	var btn:Panel = make_song_button(prev_index())
	btns.insert(0,btn) # BEFORE
	add_child(btn) 
	move_child(btn, 0) # to top
	btn.visible = true
	tween_in(btn)
	tween_length()
	
func pg_down():
	if cur_map >= disp.size() - 1: return
	cur_map += 1
	Rhythia.last_page_num = cur_map
	
	$Press.play()
	var out:Panel = btns.pop_front()
	tween_out(out) # freed in tween
#	yield(get_tree().create_timer(1),"timeout")
#	out.queue_free()
	var btn:Panel = make_song_button(next_index())
	btns.append(btn) # AFTER
	add_child(btn) # at end
	btn.visible = true
	tween_in(btn)
	tween_length()

#var last_size = OS.window_size
#func _process(delta):
#	if OS.window_size != last_size:
#		last_size = OS.window_size
#		load_pg()

func tween_out(p:Panel):
	var tween = get_tree().create_tween()
	tween.tween_property(p, "rect_min_size", Vector2(50, 0), 0.25)
	tween.tween_callback(p, "queue_free")

func tween_in(p:Panel):
	var tween = get_tree().create_tween()
	tween.tween_property(p, "rect_min_size", Vector2(50, 80), 0.25)

func tween_length():
	for i in btns.size():
		var tween = get_tree().create_tween()
		tween.tween_property(btns[i], "rect_min_size", Vector2(600-(10*(abs((page_size/2)-i))), 80), 0.25)
	

func _input(ev:InputEvent):
	if is_visible_in_tree() and ev is InputEventMouseButton and ev.is_pressed():
		if ev.button_index == BUTTON_WHEEL_UP:
			call_deferred("pg_up")
		elif ev.button_index == BUTTON_WHEEL_DOWN:
			call_deferred("pg_down")

func handle_window_resize():
	if ready: load_pg(true)

func firstload():
#	get_parent().get_node("P").connect("pressed",self,"pg_down")
#	get_parent().get_node("M").connect("pressed",self,"pg_up")
# if the button is held down, it will keep scrolling call a loop on a thread and stop it when the button is released
	get_parent().get_node("P").connect("button_down",self,"pg_down_cont")
	get_parent().get_node("M").connect("button_down",self,"pg_up_cont")
	get_parent().get_node("P").connect("button_up",self,"pg_down_stop")
	get_parent().get_node("M").connect("button_up",self,"pg_up_stop")
	
	get_parent().get_node("Random").connect("pressed",self,"select_random")
	cur_map = Rhythia.last_page_num
	prepare_songs()
	reload_to_current_page()
	ready = true
	Rhythia.connect("favorite_songs_changed",self,"reload_to_current_page")
	Rhythia.connect("download_done",self,"reload_to_current_page")
	get_viewport().connect("size_changed",self,"handle_window_resize")
	Rhythia.emit_signal("map_list_ready")

func pg_up_cont():
	scroll_up = true
	
func pg_up_stop():
	scroll_up = false

func pg_down_cont():
	scroll_down = true

func pg_down_stop():
	scroll_down = false

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
	Engine.iterations_per_second = 25
	call_deferred("firstload")
