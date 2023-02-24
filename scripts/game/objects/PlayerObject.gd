extends GameObject
class_name PlayerObject

signal hit
signal missed
signal score_changed
signal failed

@export_category("Configuration")
@export var local_player:bool = false
@export var camera_origin:Vector3 = Vector3(0,0,-3.5)

@export_category("Node Paths")
@export_node_path("Camera3D") var camera_path
@onready var camera:Camera3D = get_node(camera_path)
@export_node_path("Node3D") var cursor_path
@onready var cursor:Node3D = get_node(cursor_path)
@onready var ghost:MeshInstance3D = cursor.get_node("Ghost")

@onready var score:Score = Score.new()
var health:float = 1
var did_fail:bool = false

var cursor_position:Vector2 = Vector2.ZERO
var clamped_cursor_position:Vector2 = Vector2.ZERO

func hit_object_state_changed(state:int,object:HitObject):
	if did_fail: return
	match state:
		HitObject.HitState.HIT:
			hit.emit(object)
			score.hits += 1
			score.combo += 1
			score.sub_multiplier += 1
			if score.sub_multiplier == 8 and score.multiplier < 8:
				score.sub_multiplier = 1
				score.multiplier += 1
			score.score += 25 * score.multiplier
			health = minf(health+0.125,1)
		HitObject.HitState.MISS:
			missed.emit(object)
			score.misses += 1
			score.combo = 0
			score.sub_multiplier = 0
			score.multiplier -= 1
			health = maxf(health-0.2,0)
	score_changed.emit(score,health)
	if health == 0 and !did_fail:
		fail()

func fail():
	did_fail = true
	set_physics_process(false)
	failed.emit()

func _ready():
	set_process_input(local_player)
	set_physics_process(local_player)
	if local_player:
		camera.make_current()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
func _exit_tree():
	if local_player:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event):
	if event is InputEventMouseMotion:
		var clamp_value = 1.36875
		cursor_position -= event.relative / 100.0
		clamped_cursor_position = Vector2(
			clamp(cursor_position.x,-clamp_value,clamp_value),
			clamp(cursor_position.y,-clamp_value,clamp_value))
func _process(_delta):
	var difference = cursor_position - clamped_cursor_position
	cursor.position = Vector3(clamped_cursor_position.x,clamped_cursor_position.y,0)
	ghost.position = Vector3(difference.x,difference.y,0.01)
	ghost.transparency = max(0.25,1-(difference.length_squared()*2))
	
	var parallax = Vector3(clamped_cursor_position.x,clamped_cursor_position.y,0) / 4
	camera.position = camera_origin + parallax + camera.basis.z / 4

var latest_passed_note_index:int = 0
func _physics_process(_delta):
	var cursor_hitbox = 0.2625
	var hitwindow = 1.75/30
	var objects = manager.objects
	for object in objects.slice(latest_passed_note_index):
		if game.sync_manager.current_time < object.spawn_time:
			break
		if !(object is HitObject and object.hittable): continue
		if game.sync_manager.current_time > object.despawn_time:
			latest_passed_note_index = objects.find(object)
		if object.hit_state != HitObject.HitState.NONE: continue
		var x = abs(object.position.x - clamped_cursor_position.x)
		var y = abs(object.position.y - clamped_cursor_position.y)
		var object_scale = object.global_transform.basis.get_scale()
		var hitbox_x = (object_scale.x + cursor_hitbox) / 2.0
		var hitbox_y = (object_scale.y + cursor_hitbox) / 2.0
		if x <= hitbox_x and y <= hitbox_y: object.hit()
		elif object is NoteObject:
			if game.sync_manager.current_time > (object as NoteObject).note.time + hitwindow:
				object.miss()
		elif game.sync_manager.current_time >= object.despawn_time: object.miss()
