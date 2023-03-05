extends BaseManager
class_name ObjectManager

var origin

var objects:Array[GameObject] = []
var objects_ids:Dictionary = {}
var objects_to_process:Array[GameObject]

var player:PlayerObject

func prepare(_game:GameScene):
	super.prepare(_game)
	
	origin = game.origin
	player = game.player
	
	origin.set_physics_process(game.local_player)
	
	append_object(player,false)
	append_object(origin.get_node("World"),false)
	append_object(origin.get_node("HUD"),false)
	build_map(game.map)

func append_object(object:GameObject,parent:bool=true,include_children:bool=false):
	if objects_ids.keys().has(object.id): return false
	object.game = game
	object.manager = self
	
	object.set_physics_process(game.local_player)
	if !object.permanent: object.process_mode = Node.PROCESS_MODE_DISABLED
	object.process_priority = 4
	
	if object is HitObject:
		if player != null: object.connect(
			"on_hit_state_changed",
			Callable(player,"hit_object_state_changed").bind(object)
		)
	
	if parent: # Reparent to origin
		var current_parent = object.get_parent()
		if current_parent != origin:
			if current_parent != null:
				current_parent.remove_child(object)
			origin.add_child(object)
	
	if include_children: # Append children
		for child in object.get_children():
			if child is GameObject:
				append_object(child,false,true)
	
	objects.append(object)
	objects_ids[object.id] = object
	if !object.permanent: objects_to_process.append(object)

func build_map(map:Map):
	for note in map.notes:
		note = note as Map.Note
		var id = note.data.get("id","note-%s" % note.index)
		var object = NoteObject.new(id,note)
		var colorset = game.settings.colorset
		var colour_index = wrapi(note.index,0,colorset.size())
		var colour = colorset[colour_index]
		object.colour = Color.from_string(colour,Color.RED)
		object.spawn_distance = game.settings.approach.distance
		object.hittable = true
		object.spawn_time = note.time - (game.settings.approach.time * game.mods.speed)
		object.despawn_time = note.time + 1
		object.visible = false
		append_object(object)
	objects_to_process.sort_custom(func(a,b): return a.spawn_time < b.spawn_time)

func _process(_delta):
	for object in objects_to_process.duplicate():
		if game.sync_manager.current_time < object.spawn_time: break
		if game.sync_manager.current_time > object.despawn_time:
			if object is HitObject and object.hit_state == HitObject.HitState.NONE:
				object.miss()
			object.process_mode = Node.PROCESS_MODE_DISABLED
			objects_to_process.erase(object)
			continue
		object.process_mode = Node.PROCESS_MODE_INHERIT
