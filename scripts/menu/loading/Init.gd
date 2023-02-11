extends Node

@onready var skip_intro:bool = ProjectSettings.get_setting_with_override("application/startup/disable_intro")

@onready var tween:Tween = self.create_tween()

func _ready():
	SoundSpacePlus.warning_seen = ProjectSettings.get_setting_with_override("application/startup/disable_health_warning")
	$Pre.modulate.a = 0
	$Post.modulate.a = 0
	await get_tree().create_timer(1).timeout
	if !SoundSpacePlus.is_init:
		finish()
		return
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
	tween.kill()
	tween = create_tween()
	tween.parallel().tween_property($Pre,"modulate:a",1,2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property($Strings,"volume_db",-12,2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.play()
	await tween.finished
	await get_tree().create_timer(1).timeout
	$Pre/Continue.connect("pressed",Callable(self,"precontinue"))
	$Pre/Continue.disabled = false

func precontinue():
	$Pre/Continue.disabled = true
	tween.kill()
	tween = create_tween()
	tween.parallel().tween_property($Pre,"modulate:a",0,1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.play()
	await tween.finished
	SoundSpacePlus.init()
	if skip_intro:
		post()
		return
	intro()

func post():
	$Pre.visible = false
	$Post.visible = true
	tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($Post,"modulate:a",1,0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property($Piano,"volume_db",-8,0.5)
	tween.parallel().tween_property($Drums,"volume_db",-8,2)
	tween.parallel().tween_property($Phaser,"volume_db",-12,1.5)
	tween.parallel().tween_property($Strings,"volume_db",-12,1)
	tween.play()

func finish():
	get_tree().change_scene_to_file(ProjectSettings.get_setting("application/config/menu_scene"))

func intro():
	tween.kill()
	tween = create_tween()
	tween.parallel().tween_property($Piano,"volume_db",-80,1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.play()
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/Intro.tscn")
