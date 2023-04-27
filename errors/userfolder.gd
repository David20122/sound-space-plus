extends ColorRect

func _ready():
	Engine.target_fps = 30 # Don't use the entire GPU for the error screen
	$Info.text = """-- user folder open error --
ssp version: v%s
platform: %s
error code: %s""" % [
		ProjectSettings.get_setting("application/config/version"),
		OS.get_name(),
		Globals.errornum,
	]
	if OS.has_feature("Android"):
		OS.request_permissions()
		$Info.get("custom_fonts/font").size = 28
		$Info.text += "\n\nNote: SSP currently needs storage permissions to create its user folder.\nYou can remove the permission afterwards.\n(this'll be fixed when godot 3.5 releases)"
	if ProjectSettings.get_setting("application/config/discord_rpc"):
		var activity = Discord.Activity.new()
		activity.set_type(Discord.ActivityType.Playing)
		activity.set_details("experiencing a cattr moment")
		activity.set_state("(user folder open error %s)" % SSP.errornum)

		var assets = activity.get_assets()
		assets.set_large_image("icon-bg")
		assets.set_small_image("error")

		var result = yield(Discord.activity_manager.update_activity(activity), "result").result
		if result != Discord.Result.Ok:
			push_error(result)
