extends Control

func _ready():
	$Add.connect("pressed",Callable(self,"add"))
	$Remove.connect("pressed",Callable(self,"remove"))

func add():
	$AddWindow.popup_centered()
func remove():
	$DeleteWindow.popup_centered()
