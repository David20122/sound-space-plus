extends GameObject
class_name NoteObject

var note:Map.Note

var hittable:bool = false

func _init(id:String,note:Map.Note):
	super._init(id)
	self.note = note

func _process(_delta):
	var time = note.time-game.sync_manager.current_time
	visible = time <= 1 and time >= 0
	transform.origin = Vector3(-note.x+1,-note.y+1,time*100)
