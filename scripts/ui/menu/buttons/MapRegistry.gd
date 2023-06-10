extends GridContainer

signal search_updated

var maps:Array = []
var btns:Array = []
var current_sel:int

var search_text:String = ""
var difficulty_filter:Array = SSP.last_difficulty_filter
var show_broken_maps:bool = false

func update_search_text(txt:String):
	search_text = txt
	emit_signal("search_updated",txt,difficulty_filter,show_broken_maps)

func update_search_dfil(dfil:Array):
	difficulty_filter = dfil
	emit_signal("search_updated",search_text,dfil,show_broken_maps)
	SSP.last_difficulty_filter = dfil

func update_search_showbroken(show:bool):
	show_broken_maps = show
	emit_signal("search_updated",search_text,difficulty_filter,show_broken_maps)

func on_pressed(i):
	$Press.play()
	SSP.select_song(maps[i])

func on_map_selected(selected_map:Song):
#	text = "M: %s" % selected_set.name
	btns[current_sel].get_node("Select").pressed = false
	for i in range(maps.size()):
		var map:Song = maps[i]
		if map == selected_map:
			current_sel = i
			btns[current_sel].get_node("Select").pressed = true

var last_col = -1
func _process(delta):
	var new_col = floor(get_parent().rect_size.x / 132)
	if last_col != new_col:
		columns = new_col
		rect_min_size.x = columns * 132
		last_col = new_col

func handle_button(btn:Node):
	connect("search_updated",btn,"on_search_updated")
	add_child(btn)

func _ready():
	if !visible: return
	var found:Array = SSP.registry_song.get_items()
	var favorite:Array = []
	var easy:Array = []
	var medium:Array = []
	var hard:Array = []
	var logic:Array = []
	var amogus:Array = []
	var unknown:Array = []
	for i in range(found.size()):
		var map:Song = found[i]
		var btn:Panel
		var add_to:Array
		if map.difficulty == Globals.DIFF_EASY:
			btn = $EASY.duplicate()
			add_to = easy
		elif map.difficulty == Globals.DIFF_MEDIUM:
			btn = $MEDIUM.duplicate()
			add_to = medium
		elif map.difficulty == Globals.DIFF_HARD:
			btn = $HARD.duplicate()
			add_to = hard
		elif map.difficulty == Globals.DIFF_LOGIC:
			btn = $LOGIC.duplicate()
			add_to = logic
		elif map.difficulty == Globals.DIFF_AMOGUS:
			btn = $AMOGUS.duplicate()
			add_to = amogus
		else:
			btn = $NODIF.duplicate()
			add_to = unknown
		btn.get_node("Label").visible = false
		if map.has_cover:
			btn.get_node("Cover").visible = true
			btn.get_node("Cover").texture = map.cover
		else:
			btn.get_node("Name").visible = true
			btn.get_node("Name").text = map.name#.replacen(" - ","\n")
		maps.append(map)
		btns.append(btn)
		btn.song = map
		if map.warning != "":
			if map.is_broken: btn.get_node("Name").modulate = Color(1,0.4,0.4)
			else: btn.get_node("Name").modulate = Color(1,1,0.2)
		add_to.append(btn)
		var rbtn:Button = btn.get_node("Select")
		rbtn.disabled = false
		rbtn.connect("pressed",self,"on_pressed",[i])
		if map == SSP.selected_song:
			current_sel = i
			btn.get_node("Select").pressed = true
	for btn in favorite: handle_button(btn)
	for btn in easy: handle_button(btn)
	for btn in medium: handle_button(btn)
	for btn in hard: handle_button(btn)
	for btn in logic: handle_button(btn)
	for btn in amogus: handle_button(btn)
	for btn in unknown: handle_button(btn)
	$EASY.visible = false
	$MEDIUM.visible = false
	$HARD.visible = false
	$LOGIC.visible = false
	$AMOGUS.visible = false
	$NODIF.visible = false
	SSP.connect("selected_song_changed",self,"on_map_selected")
	SSP.emit_signal("map_list_ready")
	update_search_dfil(difficulty_filter)
	
