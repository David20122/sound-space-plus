extends ColorRect

func _ready():
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_details("experiencing a cattr moment")
	activity.set_state("(settings error %s)" % SSP.errornum)

	var assets = activity.get_assets()
	assets.set_large_image("icon")
	assets.set_small_image("error")

	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		push_error(result)
