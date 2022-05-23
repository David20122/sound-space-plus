extends GridContainer

signal search_updated

var songs:Array = SSP.registry_song.get_items()
var btns:Array = []

var search_text:String = ""
var difficulty_filter:Array = SSP.last_difficulty_filter
var show_broken_maps:bool = false
var flip_display:bool = false
var flip_name:bool = false

var page = 0

var favorite:Array = []
var easy:Array = []
var medium:Array = []
var hard:Array = []
var logic:Array = []
var amogus:Array = []
var unknown:Array = []

var disp:Array = []

func is_fav(s:Song): return favorite.has(s)
func search_matches(s:Song):
	return (
		difficulty_filter.has(s.difficulty) and
		(!s.is_broken or show_broken_maps) and
		(search_text == "" or s.name.to_lower().find(search_text.to_lower()) != -1)
	)

func on_pressed(i):
	$Press.play()
	var s:Song = disp[i]
	if s != SSP.selected_song:
		SSP.select_song(s)

func select_random():
	on_pressed(randi()%disp.size())
	for b in btns:
		if b.song == SSP.selected_song: b.get_node("Select").pressed = true
		else: b.get_node("Select").pressed = false

func load_pg():
	var col = clamp(floor(rect_size.x/132),1,10)
	if columns != col: columns = col
	var spp = clamp(col*floor(rect_size.y/132)-1,1,6*col)
	get_parent().get_node("P").rect_position.x = (col*132)+66
	get_parent().get_node("P").rect_size.y = ((spp/col)*132)+12
	get_parent().get_node("M").rect_size.y = ((spp/col)*132)+12
	for n in btns: n.queue_free()
	btns.clear()
	if floor(float(disp.size())/spp) < page: page = floor(float(disp.size())/spp)
	for i in range(page*spp,((page+1)*spp)):
		if i < disp.size():
			var map:Song = disp[i]
			var btn:Panel
			var add_to:Array
			match map.difficulty:
				Globals.DIFF_EASY: btn = $EASY.duplicate()
				Globals.DIFF_MEDIUM: btn = $MEDIUM.duplicate()
				Globals.DIFF_HARD: btn = $HARD.duplicate()
				Globals.DIFF_LOGIC: btn = $LOGIC.duplicate()
				Globals.DIFF_AMOGUS: btn = $AMOGUS.duplicate()
				_: btn = $NODIF.duplicate()
			btn.get_node("Label").visible = false
			if map.has_cover:
				btn.get_node("Cover").visible = true
				btn.get_node("Cover").texture = map.cover
			else:
				btn.get_node("Name").visible = true
				btn.get_node("Name").text = map.name
			btns.append(btn)
			btn.song = map
			if map.warning != "":
				if map.is_broken: btn.get_node("Name").modulate = Color(1,0.4,0.4)
				else: btn.get_node("Name").modulate = Color(1,1,0.2)
			var rbtn:Button = btn.get_node("Select")
			if is_fav(map): btn.get_node("F").visible = true
			rbtn.disabled = false
			rbtn.connect("pressed",self,"on_pressed",[i])
			if map == SSP.selected_song:
				btn.get_node("Select").pressed = true
			add_child(btn)
			btn.visible = true

func append_filtering_favorites(to:Array,from:Array):
	for s in from:
		if search_matches(s) and !is_fav(s):
			to.append(s)


func build_list():
	disp = []
	favorite = []
	for id in SSP.favorite_songs:
		var s = SSP.registry_song.get_item(id)
		if s and search_matches(s): favorite.append(s)
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

func reload_to_current_page():
	build_list()
	load_pg()

func update_search_text(txt:String):
	search_text = txt
	reload_to_current_page()
	emit_signal("search_updated")

func update_search_dfil(dfil:Array):
	difficulty_filter = dfil
	SSP.last_difficulty_filter = dfil
	reload_to_current_page()
	emit_signal("search_updated")

func update_search_showbroken(show:bool):
	show_broken_maps = show
	reload_to_current_page()

func update_search_flipped(flip:bool):
	flip_display = flip
	reload_to_current_page()

func update_search_flip_name(flip:bool):
	flip_name = flip
	easy.sort_custom(self,"sortsongsimple")
	medium.sort_custom(self,"sortsongsimple")
	hard.sort_custom(self,"sortsongsimple")
	logic.sort_custom(self,"sortsongsimple")
	amogus.sort_custom(self,"sortsongsimple")
	reload_to_current_page()

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
		add_to.append(map)
#	SSP.connect("selected_song_changed",self,"on_map_selected")
	easy.sort_custom(self,"sortsongsimple")
	medium.sort_custom(self,"sortsongsimple")
	hard.sort_custom(self,"sortsongsimple")
	logic.sort_custom(self,"sortsongsimple")
	amogus.sort_custom(self,"sortsongsimple")

func pg(dir:int):
	$Press.play()
	page = clamp(page + dir, 0, floor(songs.size()))
	load_pg()

#var last_size = OS.window_size
#func _process(delta):
#	if OS.window_size != last_size:
#		last_size = OS.window_size
#		load_pg()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		load_pg()

func _ready():
	randomize()
	if !visible: return
	$EASY.visible = false
	$MEDIUM.visible = false
	$HARD.visible = false
	$LOGIC.visible = false
	$AMOGUS.visible = false
	$NODIF.visible = false
	get_parent().get_node("P").connect("pressed",self,"pg",[1])
	get_parent().get_node("M").connect("pressed",self,"pg",[-1])
	get_parent().get_node("Random").connect("pressed",self,"select_random")
	prepare_songs()
	reload_to_current_page()
	SSP.connect("favorite_songs_changed",self,"reload_to_current_page")
	yield(get_tree().create_timer(0.5),"timeout")
	page = SSP.last_page_num
	load_pg()
	SSP.emit_signal("map_list_ready")
