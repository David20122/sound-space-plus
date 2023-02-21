extends BaseManager
class_name ObjectManager

@export_node_path("Node3D") var origin_path
@onready var origin = get_node(origin_path)

var objects = []
var objects_dict = {}

func _ready():
	pass

func append_object(object:GameObject):
	assert(!objects_dict.has(object.id))
	object.game = game
	objects.append(object)
	objects_dict[object.id] = object
	origin.add_child(object)

func build_map(map:Map):
	for note in map.notes:
		note = note as Map.Note
		var id = "note-%s" % note.index
		var object = NoteObject.new(id,note)
		object.process_priority = 4
		object.hittable = true
		append_object(object)
