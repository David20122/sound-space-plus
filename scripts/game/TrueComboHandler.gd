extends Label

func _ready():
	if !SSP.display_true_combo:
		visible = false
	else:
		visible = true
		
func _physics_process(delta):
	rect_position.y += (150 - rect_position.y) * 0.25
