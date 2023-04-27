extends Control

var fading:bool = false
var afading:bool = false
var wlen:float = 2
var awlen:float = 7

func _on_bedrock_finished():
	get_tree().quit()

func _ready():
	$bedrock.volume_db = linear2db(0)
	yield(get_tree().create_timer(wlen),"timeout")
	fading = true
	$bedrock.play()
	yield(get_tree().create_timer(awlen),"timeout")
	afading = true

func _physics_process(delta):
	if fading:
		$bedrock.modulate.a = lerp($bedrock.modulate.a,1,0.01)
		$bedrock.volume_db = lerp($bedrock.volume_db,linear2db(1),0.05)
	if afading:
		$arcw.modulate.a = lerp($arcw.modulate.a,1,0.05)
