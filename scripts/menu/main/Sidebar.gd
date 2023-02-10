extends Control

@onready var tween = $Tween
var showing = false

@onready var tabs = $"../Main/TabBar"
@onready var pages = [ $Buttons/Play, $Buttons/Select, $Buttons/Content, $Buttons/Credits, $Buttons/Settings ]

func _ready():
	$Open.connect("mouse_entered",Callable(self,"show_bar"))
	$"../SidebarClose".connect("mouse_entered",Callable(self,"hide_bar"))

	tabs.current_tab = 1
	$Highlight.position.y = pages[tabs.current_tab].global_position.y

	for i in range(pages.size()):
		var button = pages[i]
		button.connect("pressed",Callable(self,"_move_highlight").bind(button))
		button.connect("pressed",Callable(tabs,"set").bind("current_tab",i))

	$Buttons/Quit.connect("pressed",Callable(get_tree(),"call_deferred").bind("quit"))
func _move_highlight(button):
	var origin_y = $Highlight.position.y
	var dest_y = button.global_position.y
	$Highlight/Tween.remove_all()
	$Highlight/Tween.interpolate_property($Highlight,"position:y",origin_y,dest_y,0.2,Tween.TRANS_EXPO,Tween.EASE_OUT)
	$Highlight/Tween.start()

func show_bar():
	if showing: return
	showing = true
	$"../SidebarClose".visible = true
	$Open.visible = false
	tween.remove_all()
	tween.interpolate_property(self,"size:x",64,256,0.4,Tween.TRANS_EXPO,Tween.EASE_OUT)
	tween.interpolate_property($"../Main","modulate:a",1,0.4,0.2,Tween.TRANS_EXPO,Tween.EASE_OUT)
	tween.start()
func hide_bar():
	if !showing: return
	showing = false
	$"../SidebarClose".visible = false
	$Open.visible = true
	tween.remove_all()
	tween.interpolate_property(self,"size:x",256,64,0.4,Tween.TRANS_EXPO,Tween.EASE_OUT)
	tween.interpolate_property($"../Main","modulate:a",0.4,1,0.2,Tween.TRANS_EXPO,Tween.EASE_OUT)
	tween.start()
