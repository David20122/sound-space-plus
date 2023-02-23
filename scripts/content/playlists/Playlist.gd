extends ResourcePlus
class_name Playlist

enum PointerType {
	LOCAL_FILE,
	ONLINE
}

var cover:ImageTexture

var mapsets:Array[Mapset]
var _mapsets:Array

func load_mapsets():
	mapsets.clear()
	for pointer in _mapsets:
		match pointer.type:
			PointerType.LOCAL_FILE:
				var found = SoundSpacePlus.mapsets.items.filter(
					func(mapset): 
						return mapset.path.get_file() == pointer.pointer
				)
				mapsets.append_array(found)
				if found.size() == 0:
					var missing = Mapset.new()
					missing.id = "[MISSING]"
					missing.name = pointer.pointer
					missing.creator = "File not found"
					missing.local = true
					missing.broken = true
					mapsets.append(missing)
			PointerType.ONLINE:
				var found = SoundSpacePlus.mapsets.get_by_online_id(pointer.pointer)
				mapsets.append_array(found)
				if found.size() == 0:
					var missing = Mapset.new()
					missing.id = pointer.pointer
					missing.online_id = pointer.pointer
					missing.local = false
					SoundSpacePlus.mapsets.add_item(missing)
					mapsets.append(missing)
