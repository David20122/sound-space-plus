extends GameObject
class_name NoteObject

var note:Map.Note
var colour:Color

var hittable:bool = false

func _init(id:String,note:Map.Note):
	super._init(id)
	self.note = note
	var colours = [Color.RED,Color.DEEP_SKY_BLUE]
	colour = colours[wrap(note.index,0,colours.size())]
	scale = Vector3.ONE*0.865

func update(current_time:float):
	var time = note.time-current_time
	transform.origin = Vector3(-note.x+1,-note.y+1,time*50)
	visible = visible_at(current_time)

func visible_at(current_time:float):
	var time = note.time-current_time
	return time <= 1 and time >= 0
