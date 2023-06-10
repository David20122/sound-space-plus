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

var filetxt = ""

func update(_s=null):
	var map:Song = SSP.selected_song
	$Id.text = map.id
	$Name.text = map.name
	$Mapper.text = map.creator
	filetxt = map.musicFile
	$MusicPath.text = "(hover to show)"
	$Difficulty.text = Globals.difficulty_names.get(map.difficulty,"INVALID DIFFICULTY ID")
	$Difficulty.modulate = Globals.difficulty_colors.get(map.difficulty,Color("#ffffff"))
	$Data.text = "%s - %s notes" % [get_time_ms(map.last_ms),comma_sep(map.note_count)]
	$Warning.text = map.warning
	if map.is_broken: $Warning.set("custom_colors/font_color",Color(1,0,0))
	else: $Warning.set("custom_colors/font_color",Color(1,1,0))

func mp_hover(): $MusicPath.text = filetxt
func mp_unhover(): $MusicPath.text = "(hover to show)"

func try_open_song():
	if !SSP.selected_song.songType == Globals.MAP_SSPM:
		get_parent().get_node("PreviewMusic").on_path_press()
		OS.shell_open(ProjectSettings.globalize_path(SSP.selected_song.musicFile))

func _ready():
	SSP.connect("selected_song_changed",self,"update")
	$MusicPath.connect("pressed",self,"try_open_song")
	$MusicPath.connect("mouse_entered",self,"mp_hover")
	$MusicPath.connect("mouse_exited",self,"mp_unhover")
	if SSP.selected_song: update()
