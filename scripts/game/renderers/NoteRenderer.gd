extends ObjectRenderer
class_name NoteRenderer

var mesh:MeshPlus

func _ready():
	multimesh.instance_count = 0
	multimesh.use_colors = true
	mesh = SoundSpacePlus.blocks.get_by_id(game.settings.assets.get("block","cube"))
	multimesh.mesh = mesh.mesh
	multimesh.instance_count = 64

func render_objects(objects:Array):
	var notes = []
	for object in objects:
		if game.sync_manager.current_time < object.spawn_time: break
		if not object is NoteObject: continue
		if !object.visible: continue
		notes.append(object)
	
	var count = notes.size()
	if count > multimesh.instance_count: multimesh.instance_count = count
	multimesh.visible_instance_count = count
	
	for i in count:
		var note = notes[i]
		multimesh.set_instance_color(i,note.colour)
		multimesh.set_instance_transform(i,note.global_transform.translated(mesh.offset))
