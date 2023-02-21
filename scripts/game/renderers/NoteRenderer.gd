extends ObjectRenderer
class_name NoteRenderer

func render_objects(objects:Array):
	var notes = objects.filter(func(object): return object is NoteObject)
	multimesh.set_instance_count(notes.size())
	var i = 0
	for note in notes:
		multimesh.set_instance_transform(i,note.global_transform)
		i += 1
