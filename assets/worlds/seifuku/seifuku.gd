extends Spatial

export var twig_distance = 4

onready var Game:SongPlayerManager = get_tree().root.get_node("Song/Game")
var fading:bool = false

func _process(delta):
	$front.opacity += (0 - $front.opacity) * 0.005
	$front.translation.z += (-5 - $front.translation.z) * 0.01
	
	$twigl.translation.x += (-(abs(twig_distance)) - $twigl.translation.x) * 0.01
	$twigl.opacity += (0 - $twigl.opacity) * 0.01
	
	$twigr.translation.x += ((abs(twig_distance)) - $twigr.translation.x) * 0.01
	$twigr.opacity += (0 - $twigl.opacity) * 0.01
	
	$twigl.rotation_degrees.z += (0 - $twigl.rotation_degrees.z) * 0.005
	$twigr.rotation_degrees.z += (0 - $twigr.rotation_degrees.z) * 0.005
	
	if Game.combo % 100 == 0 and not Game.combo == 0:
		$front.opacity = 0.25
		$front.translation.z = -14.9
	if not Game.combo == 0:
		$image.opacity += (0.05 - $image.opacity) * 0.01
	if Game.combo == 0:
		$twigl.opacity = 0.1
		$twigr.opacity = 0.1
		
		$twigl.translation.x = -abs(twig_distance) * 0.5
		$twigr.translation.x = abs(twig_distance) * 0.5
		
		$twigl.rotation_degrees.z = -60
		$twigr.rotation_degrees.z = 60
