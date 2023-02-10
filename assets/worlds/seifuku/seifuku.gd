extends Node3D

@export var twig_distance = 4

@onready var Game:SongPlayerManager = get_tree().root.get_node("Song/Game")
var fading:bool = false

func _process(delta):
	$front.opacity += (0 - $front.opacity) * 0.005
	$front.position.z += (-5 - $front.position.z) * 0.01
	
	$twigl.position.x += (-(abs(twig_distance)) - $twigl.position.x) * 0.01
	$twigl.opacity += (0 - $twigl.opacity) * 0.01
	
	$twigr.position.x += ((abs(twig_distance)) - $twigr.position.x) * 0.01
	$twigr.opacity += (0 - $twigl.opacity) * 0.01
	
	$twigl.rotation_degrees.z += (0 - $twigl.rotation_degrees.z) * 0.005
	$twigr.rotation_degrees.z += (0 - $twigr.rotation_degrees.z) * 0.005
	
	if Game.combo % 100 == 0 and not Game.combo == 0:
		$front.opacity = 0.25
		$front.position.z = -14.9
	if not Game.combo == 0:
		$image.opacity += (0.05 - $image.opacity) * 0.01
	if Game.combo == 0:
		$twigl.opacity = 0.1
		$twigr.opacity = 0.1
		
		$twigl.position.x = -abs(twig_distance) * 0.5
		$twigr.position.x = abs(twig_distance) * 0.5
		
		$twigl.rotation_degrees.z = -60
		$twigr.rotation_degrees.z = 60
