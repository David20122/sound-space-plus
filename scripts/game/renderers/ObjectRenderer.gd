extends MultiMeshInstance3D
class_name ObjectRenderer

func _process(_delta):
	var objects = (get_parent() as ObjectManager).objects
	var visible_objects = objects.filter(func(object): return object.visible)
	self.render_objects(visible_objects)

func render_objects(objects:Array):
	pass
