extends Registry
class_name MapsetRegistry

func add_mapset(item:Mapset):
	add_item(item)

func get_by_online_id(id:String):
	return items.filter(func(set): set.online_id == id)
