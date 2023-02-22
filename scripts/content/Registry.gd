extends Resource
class_name Registry

@export var items:Array[ResourcePlus] = []

func get_ids():
	return items.map(func(item): return item.id)

func get_by_id(id:String):
	var ids = get_ids()
	if !ids.has(id): return null
	return items[ids.find(id)]
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
	var ids = get_ids()
	if !ids.has(id): return
	var index = ids.find(id)
	var item = items[index]
	items.remove_at(index)
	item.free()

func clear():
	for item in items:
		item.free()
	items.clear()
