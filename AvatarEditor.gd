extends Control

func _ready():
	$VPContainer/VP/Avatar/Animations.play("Idle")
	$VPContainer/VP/Avatar/Head/Blinking.play("Blink")
