extends Panel

var open:bool = false
var open_amt:float = 1

onready var pages:Array = [
	get_node("../Main/Results"),
	get_node("../Main/MapRegistry"),
	get_node("../Main/Settings"),
	get_node("../Main/Credits")
]
onready var buttons:Array = [
	$L/Results,
	$L/MapSelect,
	$L/Settings,
	$L/Credits
]
var use_ver_b:Array = [
	false,
	false,
	true,
	false
]

func press(bi:int,q:bool=false):
	if !q: get_node("../Press").play()
	for i in range(pages.size()):
		pages[i].visible = i == bi
		buttons[i].pressed = i == bi
	yield(get_tree(),"idle_frame")
	open = false
	get_node("../VersionNumber").visible = !use_ver_b[bi]
	get_node("../VersionNumberB").visible = use_ver_b[bi]
	get_node("Click").visible = !open
	get_node("../SidebarClick").visible = open

func to_old_menu():
	get_node("../Press").play()
	get_viewport().get_node("Menu").black_fade_target = true
	if Input.is_key_pressed(KEY_C):
		if !SSP.selected_song:
			Globals.notify(Globals.NOTIFY_WARN,"No selected song","Automatically selecting a song")
			SSP.select_song(SSP.registry_song.items[0])
		SSP.menu_target = "res://classes/cursordance/dancetest.tscn"
	else: SSP.menu_target = "res://menu.tscn"
	yield(get_tree().create_timer(0.35),"timeout")
	get_tree().change_scene("res://menuload.tscn")

func to_content_mgr():
	get_node("../Press").play()
	get_viewport().get_node("Menu").black_fade_target = true
	yield(get_tree().create_timer(0.35),"timeout")
	SSP.conmgr_transit = "addsongs"
	get_tree().change_scene("res://contentmgrload.tscn")

func to_vr():
	get_node("../Press").play()
	get_viewport().get_node("Menu").black_fade_target = true
	yield(get_tree().create_timer(0.35),"timeout")
	SSP.start_vr()

func quit():
	get_node("../Press").play()
	get_viewport().get_node("Menu").black_fade_target = true
	yield(get_tree().create_timer(0.35),"timeout")
	get_tree().quit()
	

func _ready():
	for i in range(buttons.size()):
		buttons[i].connect("pressed",self,"press",[i])
	
	if SSP.just_ended_song: press(0,true)
	else: press(1,true)
	
	$L/OldMenu.connect("pressed",self,"to_old_menu")
	$L/ContentMgr.connect("pressed",self,"to_content_mgr")
	$L/StartVR.connect("pressed",self,"to_vr")
	$L/Quit.connect("pressed",self,"quit")
	
	$L/ContentMgr.visible = not SSP.vr
	$L/StartVR.visible = SSP.vr_available and not SSP.vr
	if SSP.vr or !OS.has_feature("pc"):
		$L/Quit/Label.text = "Quit to Home" 
	

func _process(delta:float):
	if open == true and open_amt != 1:
		open_amt = min(open_amt + max((1 - open_amt) * delta * 14, 0.05*delta),1)
#		if open_amt > 0.99: open_amt = 1
	elif open == false and open_amt != 0:
		open_amt = max(open_amt + min((0 - open_amt) * delta * 12, -0.05*delta),0)
#		if open_amt < 0.01: open_amt = 0
	
	rect_size.x = 60 + (180 * open_amt)

func _input(ev):
	if (ev is InputEventScreenTouch or ev is InputEventMouseButton):
		if ev.pressed != true: return
		open = ev.position.x < rect_size.x and ev.position.y < rect_size.y
		yield(get_tree(),"idle_frame")
		get_node("Click").visible = !open
		get_node("../SidebarClick").visible = open
