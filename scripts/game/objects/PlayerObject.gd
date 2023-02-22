extends GameObject
class_name PlayerObject

@export_category("Configuration")
@export var local_player:bool = false
@export var camera_origin:Vector3 = Vector3(0,0,-3.5)

@export_category("Node Paths")
@export_node_path("Camera3D") var camera_path
@onready var camera:Camera3D = get_node(camera_path)
@export_node_path("Node3D") var cursor_path
@onready var cursor:Node3D = get_node(cursor_path)
@onready var ghost:MeshInstance3D = cursor.get_node("Ghost")

var cursor_position:Vector2 = Vector2.ZERO
var clamped_cursor_position:Vector2 = Vector2.ZERO

func _ready():
	if local_player:
		camera.make_current()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
func _exit_tree():
	if local_player:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(_delta):
	var difference = cursor_position - clamped_cursor_position
	cursor.position = Vector3(clamped_cursor_position.x,clamped_cursor_position.y,0)
	ghost.position = Vector3(difference.x,difference.y,0.01)
	ghost.transparency = max(0.25,1-(difference.length_squared()*2))
	
	var parallax = Vector3(clamped_cursor_position.x,clamped_cursor_position.y,0) / 4
	camera.position = camera_origin + parallax + camera.basis.z / 4

var latest_passed_note_index:int = 0
func _physics_process(_delta):
	var hitbox = 0.56875
	var hit_objects = manager.objects
#	var hit_objects = manager.objects.filter(func(object): return (object is HitObject) and object.can_hit)
	for object in hit_objects.slice(latest_passed_note_index):
		if game.sync_manager.current_time < object.spawn_time:
			break
		if game.sync_manager.current_time >= object.despawn_time:
			latest_passed_note_index = hit_objects.find(object)
			continue
		if !((object is HitObject) and object.can_hit): continue
		var x = abs(object.position.x - clamped_cursor_position.x)
		var y = abs(object.position.y - clamped_cursor_position.y)
		if x <= hitbox and y <= hitbox: object.hit()

func _input(event):
	if event is InputEventMouseMotion:
		var clamp_value = 1.36875
		cursor_position -= event.relative / 200.0
		clamped_cursor_position = Vector2(
			clamp(cursor_position.x,-clamp_value,clamp_value),
			clamp(cursor_position.y,-clamp_value,clamp_value))
