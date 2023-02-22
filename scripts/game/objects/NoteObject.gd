extends HitObject
class_name NoteObject

var note:Map.Note
var colour:Color

func _init(_id:String=name,note:Map.Note=null):
	super._init(_id)
	self.note = note
	var colours = [Color.RED,Color.DEEP_SKY_BLUE]
	colour = colours[wrap(note.index,0,colours.size())]
	scale = Vector3.ONE*0.865

func _physics_process(_delta):
	var time = note.time-game.sync_manager.current_time
	can_hit = hittable and time <= 0 and hit_state == HitState.NONE
	if can_hit and time < -1.75/30:
		call_deferred("miss")

func update(current_time:float):
	visible = visible_at(current_time)
	if !visible: return
	var time = note.time-current_time
	transform.origin = Vector3(-note.x+1,-note.y+1,time*50)

func visible_at(current_time:float):
	if hit_state != HitState.NONE: return false
	var time = note.time-current_time
	return time <= 1
