extends HUDItem
class_name LeftHUD

var score:Score
var ranked:bool = false
var pp:int = 0

var displayed_pp:int = 0
var displayed_score:int = 0
var visible_score:int = 0
var displayed_accuracy:float = 0

var tween:Tween

func _ready():
	$PP.text = "0"
	$PP/Unranked.visible = false
	$Score.text = "0"
	$Accuracy.text = "-"

func _process(_delta):
	if score == null: return
	if ranked and displayed_pp != pp:
		displayed_pp = pp
		$PP.text = str(pp)
	elif !ranked:
		$PP.text = ""
		$PP/Unranked.visible = true
	if displayed_score != score.score:
		if tween != null: tween.kill()
		displayed_score = score.score
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		tween.tween_property(self,"visible_score",displayed_score,0.35)
		tween.play()
	$Score.text = HUDManager.comma_sep(visible_score)
	if score.total > 0:
		$Accuracy.text = "%.2f%%" % (float(score.hits*100)/float(score.total))
	$Rank.text = score.rank
