extends Node

onready var rootg = get_tree().root
onready var real_console = $ConsoleWindow
#var fake_consoles = []

#func _process(delta):
#	if get_parent().get_child(0) != self: raise()

func ensure_console_is_in_world(_n):
	if get_parent().get_child(0) != self: raise()

##	var world = rootg.get_child(rootg.get_child_count()-1)
#	if node:
#		if node.get_path_to(rootg) == "..":
#			#if fake_consoles.size():
#				for i in range(fake_consoles.size()): 
#					fake_consoles.remove(0)
#			#var new_console = real_console.duplicate()
#			#fake_consoles.append(new_console)
#			#node.add_child(new_console)

func clear():
	real_console.clear(true)

func close():
	real_console.close(true)

#func _process(delta): raise()

func _ready():
	get_tree().connect("node_added",self,"ensure_console_is_in_world")
	call_deferred("raise")
#	ensure_console_is_in_world(rootg.get_child(rootg.get_child_count()-1))
