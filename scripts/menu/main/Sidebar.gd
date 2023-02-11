extends Control

@onready var tween:Tween = self.create_tween()
@onready var highlight_tween:Tween = self.create_tween()
var showing = false

@onready var tabs = $"../Main/TabBar"
@onready var pages = [ $Buttons/Play, $Buttons/Select, $Buttons/Content, $Buttons/Credits, $Buttons/Settings ]

func _ready():
	$Open.connect("mouse_entered",Callable(self,"show_bar"))
	$"../SidebarClose".connect("mouse_entered",Callable(self,"hide_bar"))

	for i in range(pages.size()):
		var button = pages[i]
		button.connect("pressed",Callable(self,"_move_highlight").bind(button))
		button.connect("pressed",Callable(tabs,"set").bind("current_tab",i))

	$Buttons/Quit.connect("pressed",Callable(get_tree(),"call_deferred").bind("quit_animated"))
	
	tabs.current_tab = 1
	call_deferred("_move_highlight", pages[1])
func _move_highlight(button):
	var dest_y = button.global_position.y
	highlight_tween.kill()
	highlight_tween = create_tween()
	highlight_tween.parallel().tween_property($Highlight,"position:y",dest_y,0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	highlight_tween.play()

func show_bar():
	if showing: return
	showing = true
	$"../SidebarClose".visible = true
	$Open.visible = false
	tween.kill()
	tween = create_tween()
	tween.parallel().tween_property(self,"size:x",256,0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($"../Main","modulate:a",0.4,0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.play()
func hide_bar():
	if !showing: return
	showing = false
	$"../SidebarClose".visible = false
	$Open.visible = true
	tween.kill()
	tween = create_tween()
	tween.parallel().tween_property(self,"size:x",64,0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($"../Main","modulate:a",1,0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.play()
