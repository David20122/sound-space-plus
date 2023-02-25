extends HUDItem
class_name EnergyHUD

var health:float = 5
var displayed_health:float = 5

var tween:Tween
 
func _ready():
	$Health.value = 5

func _process(_delta):
	if health != displayed_health:
		if tween != null: tween.kill()
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property($Health,"value",health,0.1)
		tween.play()
		displayed_health = health
