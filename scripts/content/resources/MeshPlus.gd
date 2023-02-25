extends ResourcePlus
class_name MeshPlus

@export var mesh:Mesh
@export var offset:Vector3 = Vector3.ZERO

func _init(_mesh:Mesh=null,_offset:Vector3=Vector3.ZERO):
	mesh = _mesh
	offset = _offset
