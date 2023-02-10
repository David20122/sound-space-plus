extends Node2D

func _ready():
	update_activity()

func update_activity() -> void:
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_state("market your game checked Discord!!!")
	activity.set_details("Use your player base to")

	var assets = activity.get_assets()
	assets.set_large_image("godot")
	assets.set_large_text("ZONE 2 WOOO")
	assets.set_small_image("capsule_main")
	assets.set_small_text("ZONE 2 WOOO")
	
	var timestamps = activity.get_timestamps()
	timestamps.set_start(Time.get_unix_time_from_system() + 100)
	timestamps.set_end(Time.get_unix_time_from_system() + 500)

	var result = await Discord.activity_manager.update_activity(activity).result.result
	if result != Discord.Result.Ok:
		push_error(str(result))
