extends HUDItem
class_name RightHUD

var score:Score

var displayed_combo:int = 0
var displayed_misses:int = 0
var displayed_multiplier:int = 0
var displayed_submultiplier:int = 0

var tween:Tween

func _ready():
	$Combo.text = "0"
	$Misses.text = "0"
	$Multiplier/Label.text = "1x"
	$Multiplier/Progress.value = 0

func _process(_delta):
	if score == null: return
	if displayed_combo != score.combo:
		displayed_combo = score.combo
		$Combo.text = HUDManager.comma_sep(score.combo)
	if displayed_misses != score.misses:
		displayed_misses = score.misses
		$Misses.text = HUDManager.comma_sep(score.misses)
	if displayed_multiplier != score.multiplier:
		displayed_multiplier = score.multiplier
		$Multiplier/Label.text = "%sx" % score.multiplier
	if displayed_submultiplier != score.sub_multiplier:
		if tween != null: tween.kill()
		displayed_submultiplier = score.sub_multiplier
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property($Multiplier/Progress,"value",score.sub_multiplier,0.1)
		tween.play()
