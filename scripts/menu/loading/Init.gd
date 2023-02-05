extends Node

onready var skip_intro:bool = ProjectSettings.get_setting("application/startup/disable_intro")

func _ready():
	SoundSpacePlus.warning_seen = ProjectSettings.get_setting("application/startup/disable_health_warning")
	$Pre.modulate.a = 0
	$Post.modulate.a = 0
	yield(get_tree().create_timer(1),"timeout")
	if !SoundSpacePlus.is_init:
		finish()
		return
	SoundSpacePlus.connect("on_init_complete",self,"finish",[],4)
	if !SoundSpacePlus.warning_seen:
		SoundSpacePlus.warning_seen = true
		pre()
		return
	if SoundSpacePlus.loading:
		post()
		return
	post()
	SoundSpacePlus.init()

func pre():
	$Post.visible = false
	$Pre.visible = true
	$Pre/Continue.disabled = true
	$Piano.volume_db = -8
	$Piano.seek(0)
	$Tween.remove_all()
	$Tween.interpolate_property($Pre,"modulate:a",0,1,2,Tween.TRANS_EXPO,Tween.EASE_IN)
	$Tween.interpolate_property($Strings,"volume_db",-80,-12,2,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween,"tween_completed")
	yield(get_tree().create_timer(1),"timeout")
	$Pre/Continue.connect("pressed",self,"precontinue")
	$Pre/Continue.disabled = false

func precontinue():
	$Pre/Continue.disabled = true
	$Tween.remove_all()
	$Tween.interpolate_property($Pre,"modulate:a",1,0,1,Tween.TRANS_EXPO,Tween.EASE_OUT)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	SoundSpacePlus.init()
	if skip_intro:
		post()
		return
	intro()

func post():
	$Pre.visible = false
	$Post.visible = true
	$Tween.remove_all()
	$Tween.interpolate_property($Post,"modulate:a",0,1,0.2,Tween.TRANS_EXPO,Tween.EASE_IN)
	$Tween.interpolate_property($Piano,"volume_db",$Piano.volume_db,-8,0.5,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.interpolate_property($Drums,"volume_db",$Drums.volume_db,-8,2,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.interpolate_property($Phaser,"volume_db",$Phaser.volume_db,-12,1.5,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.interpolate_property($Strings,"volume_db",$Strings.volume_db,-12,1,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.start()

func finish():
	get_tree().change_scene(ProjectSettings.get_setting("application/config/menu_scene"))

func intro():
	$Tween.remove_all()
	$Tween.interpolate_property($Piano,"volume_db",$Piano.volume_db,-80,1,Tween.TRANS_SINE,Tween.EASE_OUT)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	get_tree().change_scene("res://scenes/Intro.tscn")
