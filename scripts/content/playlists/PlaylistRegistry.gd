extends Registry
class_name PlaylistRegistry

func add_playlist(item:Playlist):
	add_item(item)

func get_by_online_id(id:String):
	return items.filter(func(set): set.online_id == id)
