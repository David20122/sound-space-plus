extends MenuButton

var meshes:Array = []
var current_sel:int

func on_pressed(i):
	Rhythia.select_mesh(meshes[i])

func on_mesh_selected(selected_mesh:NoteMesh):
	text = selected_mesh.name
	get_popup().set_item_checked(current_sel,false)
	for i in range(meshes.size()):
		var mesh:NoteMesh = meshes[i]
		if mesh == selected_mesh:
			current_sel = i
			
			get_popup().set_item_checked(i,true)

func _ready():
	var found:Array = Rhythia.registry_mesh.get_items()
	for i in range(found.size()):
		var mesh:NoteMesh = found[i]
		get_popup().add_check_item(mesh.name,i)
		meshes.append(mesh)
		if mesh == Rhythia.selected_mesh:
			current_sel = i
			get_popup().set_item_checked(i,true)
	Rhythia.connect("selected_mesh_changed",self,"on_mesh_selected")
	get_popup().connect("id_pressed",self,"on_pressed")
	on_mesh_selected(Rhythia.selected_mesh)
