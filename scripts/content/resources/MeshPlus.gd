extends ResourcePlus
class_name MeshPlus

@export var mesh:Mesh:
	get:
		var no_surfaces = mesh.get_surface_count()
		var no_materials = materials.size()
		for i in range(no_surfaces):
			var mat_i = wrap(i,0,no_materials)
			mesh.surface_set_material(i,materials[mat_i])
		return mesh
@export var materials:Array[Material]

func _init(_mesh:Mesh=null,_materials:Array[Material]=[]):
	mesh = _mesh
	materials = _materials
