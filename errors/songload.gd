extends ColorRect

func _ready():
	$Info.text = """-- song player load error --
ss+ version: v%s
platform: %s
error info: %s""" % [
		ProjectSettings.get_setting("application/config/version"),
		OS.get_name(),
		SSP.errorstr,
	]
	if OS.has_feature("mobile"):
		$Info.get("custom_fonts/font").size = 28
	if ProjectSettings.get_setting("application/config/discord_rpc"):
		var activity = Discord.Activity.new()
		activity.set_type(Discord.ActivityType.Playing)
		activity.set_details("experiencing a cattr moment")
		activity.set_state("(song player loading error)")

		var assets = activity.get_assets()
		assets.set_large_image("icon")
		assets.set_small_image("error")

		var result = yield(Discord.activity_manager.update_activity(activity), "result").result
		if result != Discord.Result.Ok:
			push_error(result)
