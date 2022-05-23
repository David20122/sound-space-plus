extends Panel

var song:Song

func on_search_updated(txt:String,dfil:Array,showBroken:bool):
	var lower = txt.to_lower()
	visible = (
		(txt == "")
		or (song.id.to_lower().find(lower) != -1)
		or (song.name.to_lower().find(lower) != -1)
		or (song.warning.to_lower().find(lower) != -1)
	) and dfil.has(song.difficulty) and (showBroken or !song.is_broken)
