extends Spatial

var active:bool = false
var rainbow:bool = false
var col:Color = Color(1,1,1,1)
var t:float = 1

func _ready():
	$Label.billboard = SSP.billboard_score

func _process(delta):
	if active:
		t -= delta * 3
		transform.origin.y = -0.8 + clamp((2*pow((1.0 - t)-0.25,2))-0.125,-1,1) * -0.4
		$Label.modulate = Color(col.r, col.g, col.b, col.a*t)
		$Label.outline_modulate = Color(0, 0, 0, 0.6*t)
		if t <= 0:
			active = false
			queue_free()


func spawn(parent:Node,pos:Vector3,color:Color,score:int):
	col = color * Color(1,1,1,0.5)
	
	if (score > 0): $Label.text = "+" + Globals.comma_sep(score)
	else: $Label.text = Globals.comma_sep(score)
	
	transform.origin = Vector3(pos.x,-0.8,pos.z)
	parent.add_child(self)
	visible = true
	active = true
