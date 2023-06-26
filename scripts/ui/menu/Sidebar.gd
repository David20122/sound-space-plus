extends Control

onready var tween:SceneTreeTween = self.create_tween()
onready var highlight_tween:SceneTreeTween = self.create_tween()
var showing = false

onready var tabs = $"../TabBar"
onready var pages = [ $Buttons/Results, $Buttons/MapSelect, $Buttons/ContentMgr, $Buttons/Credits, $Buttons/Settings ]

func _ready():
	$Open.connect("mouse_entered",self,"show_bar")
	$"../SidebarClose".connect("mouse_entered",self,"hide_bar")

	for i in range(pages.size()):
		var button = pages[i]
		button.connect("pressed",self,"goto",[i])

	$Buttons/Quit.connect("pressed",get_tree(),"call_deferred",["quit",1])
	
	call_deferred("goto", 1)
func goto(i):
	tabs.call_deferred("set","current_tab",i)
	_move_highlight(pages[i])
func _move_highlight(button):
	var dest_y = button.rect_position.y
	highlight_tween.kill()
	highlight_tween = create_tween()
	highlight_tween.parallel().tween_property($Highlight,"rect_position:y",dest_y,0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	highlight_tween.play()

func show_bar():
	if showing: return
	showing = true
	$"../SidebarClose".mouse_filter = MOUSE_FILTER_STOP
	$Open.visible = false
	$"../SidebarClose".modulate.a = 0
	$"../SidebarClose".visible = true
	tween.kill()
	tween = create_tween()
	tween.parallel().tween_property(self,"rect_size:x",320.0,0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($"../SidebarClose","modulate:a",0.4,0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.play()
func hide_bar():
	if !showing: return
	showing = false
	$"../SidebarClose".mouse_filter = MOUSE_FILTER_IGNORE
	$Open.visible = true
	tween.kill()
	tween = create_tween()
	tween.parallel().tween_property(self,"rect_size:x",64.0,0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($"../SidebarClose","modulate:a",0.0,0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.play()
	yield(tween,"finished")
	$"../SidebarClose".visible = false
