extends Node

func _ready():
	$Pre.modulate.a = 0
	if SoundSpacePlus.first_load:
		SoundSpacePlus.init()
		pre()
		return
	post()

func pre():
	$Pre/Continue.disabled = true
	$Tween.interpolate_property($Pre,"modulate:a",0,1,1,Tween.TRANS_EXPO,Tween.EASE_IN)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	yield(get_tree().create_timer(2),"tween_all_completed")
	$Pre/Continue.connect("pressed",self,"precontinue")
	$Pre/Continue.disabled = false

func precontinue():
	$Tween.interpolate_property($Pre,"modulate:a",1,0,1,Tween.TRANS_EXPO,Tween.EASE_OUT)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	get_tree().change_scene("res://scenes/Intro.tscn")

func post():
	pass