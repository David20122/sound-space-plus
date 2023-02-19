extends RefCounted
class_name Registry

var items = []
var items_ids = {}

func get_by_id(id:String):
	if !items_ids.has(id): return false
	return items[items_ids[id]]

func add_item(item:ResourcePlus):
	assert(item.id)
	if items_ids.has(item.id): return false
	items.append(item)
	items_ids[item.id] = items.size() - 1
	return true

func remove_item(item:ResourcePlus):
	items.remove_at(items_ids[item.id])
	_reset_ids()
	item.free()
func remove_by_id(id:String):
	var item = items_ids[id]
	items.remove_at(items_ids[id])
	_reset_ids()
	item.free()

func clear():
	for item in items:
		item.free()
	items.clear()
	items_ids.clear()

func _reset_ids():
	items_ids = {}
	for i in range(items.size()):
		items_ids[items[i].id] = i
