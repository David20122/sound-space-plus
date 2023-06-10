extends Control

func _on_Pause_pressed():
	Input.action_press("pause")
	
func _on_Pause_released():
	Input.action_release("pause")
	
func _on_GiveUp_pressed():
	Input.action_press("give_up")
	
func _on_GiveUp_released():
	Input.action_release("give_up")

func _ready():
	var tween:Tween = Tween.new()
	add_child(tween)
	
	$Pause/Button.visible = OS.has_feature("Android")
	$GiveUp/Button.visible = OS.has_feature("Android")
	
	if SSP.mirror_buttons:
		$Pause/Button.position.x = OS.get_window_safe_area().size.x - 150
		$GiveUp/Button.position.x = OS.get_window_safe_area().size.x - 150
	
	tween.interpolate_property($Pause, "modulate", Color(1,1,1,0.5), Color(1,1,1,0), 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 1)
	tween.start()
	tween.interpolate_property($GiveUp, "modulate", Color(1,1,1,0.5), Color(1,1,1,0), 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 1)
	tween.start()
