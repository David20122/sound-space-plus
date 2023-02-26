extends ObjectRenderer
class_name NoteRenderer

var mesh:MeshPlus

func _ready():
	multimesh.instance_count = 0
	multimesh.use_colors = true
	mesh = SoundSpacePlus.blocks.get_by_id(game.settings.assets.get("block","cube"))
	multimesh.mesh = mesh.mesh
	multimesh.instance_count = 64

var latest_passed_note_index:int = 0
func render_objects(objects:Array):
	objects = objects.slice(latest_passed_note_index)
	var notes = []
	var latest_passed = 0
	for i in objects.size():
		var object = objects[i]
		if not object is NoteObject: continue
		if game.sync_manager.current_time < object.spawn_time:
			break
		if game.sync_manager.current_time > object.despawn_time:
			latest_passed = i
			continue
		if !object.visible: continue
		notes.append(object)
	latest_passed_note_index += latest_passed
	var count = notes.size()
	if count > multimesh.instance_count: multimesh.instance_count = count
	multimesh.visible_instance_count = count
	var i = 0
	for note in notes:
		multimesh.set_instance_color(i,note.colour)
		multimesh.set_instance_transform(i,note.global_transform.translated(mesh.offset))
		i += 1
