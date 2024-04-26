extends Control

func comma_sep(number):
	var string = str(number)
	var mod = string.length() % 3
	var res = ""
	
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]
	
	return res

func get_time_ms(ms:float):
	var s = max(floor(ms / 1000),0)
	var m = floor(s / 60)
	var rs = fmod(s,60)
	return "%d:%02d" % [m,rs]

onready var difficulty_btns:Array = [
	$RS/H1/ButtonDisp/NODIF,
	$RS/H1/ButtonDisp/EASY,
	$RS/H1/ButtonDisp/MEDIUM,
	$RS/H1/ButtonDisp/HARD,
	$RS/H1/ButtonDisp/LOGIC,
	$RS/H1/ButtonDisp/TASUKETE
]

func update(_s=null):
	if !Rhythia.selected_song: return
	$RS.visible = true
	var map:Song = Rhythia.selected_song
#	$Deleted.visible = (map.id == "!DELETED")
	$RS.visible = (map.id != "!DELETED")
	$RS/H2/EndInfo.visible = true
	$RS/H1/Info/M/V/Buttons/Control/Actions.visible = true
#	$Actions.visible = true
	$RS/H1/Info/M/V/Id/L.text = map.id
	$RS/H1/Info/M/V/Name/L.text = map.name
	$RS/H1/Info/M/V/SongName/L.text = map.song
#	$RS/H1/Info/M/V/SongName.visible = map.name != map.song
	$RS/H1/Info/M/V/Mapper/L.text = map.creator
	$RS/HMid/Difficulty.text = map.custom_data.get("difficulty_name",
		Globals.difficulty_names.get(map.difficulty,"INVALID DIFFICULTY ID")
	)
	$RS/HMid/Difficulty.modulate = Globals.difficulty_colors.get(map.difficulty,Color("#ffffff"))
	$RS/H1/Info/D/Data.text = "%s - %s notes" % [get_time_ms(map.last_ms),comma_sep(map.note_count)]
	
	$RS/HMid/Difficulty.visible = true
	
	$RS/H1/Info/M/V/Mapper.visible = !Rhythia.single_map_mode_txt
	$RS/H1/Info/M/V/Id.visible = !Rhythia.single_map_mode_txt
	$RS/H1/Info/M/V/SMM.visible = Rhythia.single_map_mode
	
	
	var txt = ""
	if Rhythia.note_hitbox_size == 1.140: txt += tr("Default hitboxes, ")
	else: txt += tr("Hitboxes: %s, ") % Rhythia.note_hitbox_size
	if Rhythia.hitwindow_ms == 55: txt += tr("default hitwindow")
	else: txt += tr("hitwindow: %s ms") % Rhythia.hitwindow_ms
	$RS/HMid/Hitboxes.text = txt
	
	for i in range(difficulty_btns.size()):
		var n:Panel = difficulty_btns[i]
		n.visible = (map.difficulty == i-1)
		n.get_node("F").visible = Rhythia.is_favorite(map.id)
		if map.has_cover:
			n.get_node("Name").visible = false
			n.get_node("Cover").visible = true
			n.get_node("Cover").texture = map.cover
		else:
			n.get_node("Cover").visible = false
			n.get_node("Name").visible = true
			n.get_node("Name").text = map.name
	
	if map.warning != "":
		$RS/H1/Info/M/V/Warning.visible = true
		$RS/H1/Info/M/V/Warning/L.text = map.warning
		if map.is_broken:
			$RS/H1/Info/M/V/Warning/L.set("custom_colors/font_color",Color(1,0,0))
#			$Info/M/V/Run/Run.disabled = true
#			$Info/M/V/Buttons/Control/Favorite.disabled = true
#			$Info/M/V/Buttons/Control/PreviewMusic.disabled = true
		else:
			$RS/H1/Info/M/V/Warning/L.set("custom_colors/font_color",Color(1,1,0))
#			$Info/M/V/Run/Run.disabled = false
#			$Info/M/V/Buttons/Control/Favorite.disabled = false
#			$Info/M/V/Buttons/Control/PreviewMusic.disabled = false
	else: $RS/H1/Info/M/V/Warning.visible = false
	$RS/H1/Info/M/V/Run/Run.disabled = false
	$RS/H1/Info/M/V/Buttons/Control/Actions.disabled = false
	$RS/H1/Info/M/V/Buttons/Control/PreviewMusic.disabled = false
	
	$Actions/Convert.disabled = (
		$Actions/Convert.debounce or
		Rhythia.selected_song.is_broken or
		Rhythia.selected_song.is_builtin or
		Rhythia.selected_song.converted or
		Rhythia.selected_song.songType == Globals.MAP_SSPM2 or
		Rhythia.selected_song.is_online
	)
	
	$Actions/Convert.visible = (
		!Rhythia.selected_song.is_builtin and
		!Rhythia.selected_song.is_online and
		Rhythia.selected_song.songType != Globals.MAP_SSPM2
	)
	
	$Actions/Difficulty.visible = (
		!Rhythia.selected_song.is_builtin and
		!Rhythia.selected_song.is_online and (
			Rhythia.selected_song.songType == Globals.MAP_SSPM or
			Rhythia.selected_song.songType == Globals.MAP_SSPM2
		)
	)
	
	if Rhythia.selected_song.songType == Globals.MAP_SSPM:
		$Actions/Convert.text = "Upgrade map to SSPM v2"
	else:
		$Actions/Convert.text = "Convert map to .sspm"
	
	# give the containers time to update
	if is_inside_tree():
		yield(get_tree(),"idle_frame")
		yield(get_tree(),"idle_frame")
#		if $RS/H1/Info.rect_size.y > 245:
#			$Actions.rect_position.y = $RS/H1/Info.rect_size.y + 35
#			$RS/H2/EndInfo.rect_position.y = $RS/H1/Info.rect_size.y + 35
#		else:
#			$Actions.rect_position.y = 280
#			$RS/H2/EndInfo.rect_position.y = 280

func return_to_song_select():
	get_viewport().get_node("Menu/Sidebar").press(0,false)

func _ready():
	Rhythia.connect("selected_song_changed",self,"update")
	Rhythia.connect("mods_changed",self,"update")
	Rhythia.connect("favorite_songs_changed",self,"update")
#	$ButtonDisp/Select.connect("pressed",self,"return_to_song_select")
	if Rhythia.selected_song: update()
	else:
		$RS.visible = false
		$RS/H2/EndInfo.visible = false
		$RS/H1/Info/M/V/Run/Run.disabled = true
		$RS/H1/Info/M/V/Buttons/Control/Actions.disabled = true
		$RS/H1/Info/M/V/Buttons/Control/PreviewMusic.disabled = true
