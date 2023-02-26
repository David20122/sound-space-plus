extends Node3D

var rate:float = 3.5
var s:float = 6
var e:float = 80
var tcol:Color
var color:Color = Color.WHITE
var ratec:float = 0.02

var game:GameScene

func hit(note:HitObject):
	if not note is NoteObject: return
	color = note.colour

func _ready():
	game = get_meta("game")
	game.player.connect("hit",Callable(self,"hit"))

func _process(delta):
	$tunnel.position.z -= rate * game.sync_manager.playback_speed * delta
	$tunnel.position.z = wrapf($tunnel.position.z,s,e)
	tcol = color
	$tunnel.material_override.albedo_color = lerp($tunnel.material_override.albedo_color,tcol,ratec)
