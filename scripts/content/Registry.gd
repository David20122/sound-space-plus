extends Resource
class_name Registry

@export var items:Array[ResourcePlus] = []

func get_by_id(id:String):
	if !items.any(func(item): item.id == id): return false
	return items.filter(func(item): item.id == id)[0]
func get_by_online_id(id:String):
	return items.filter(func(item): item.online_id == id)

func add_item(item:ResourcePlus):
	assert(item.id)
	if items.has(item): return false
	items.append(item)
	return true

func remove_item(item:ResourcePlus):
	items.remove_at(items.find(item))
	item.free()
func remove_by_id(id:String):
	var item = get_by_id(id)
	if !item: return
	items.remove_at(items.find(item))
	item.free()

func clear():
	for item in items:
		item.free()
	items.clear()
