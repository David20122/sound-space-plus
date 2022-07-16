# Godot Editor Discord Presence Plugin
# https://github.com/3ddelano/godot-editor-discord-presence
# Author: (3ddelano) Delano Lourenco
# For license: See LICENSE.md

tool
extends EditorPlugin
const DEBUG = false
const RECONNECT_DURATION = 60

const _2D = "2D"
const _3D = "3D"
const SCENE_EDITORS = [_2D, _3D]
const SCRIPT = "Script"
const ASSETLIB = "AssetLib"

const GDSCRIPT = "GDScript"
const VISUALSCRIPT = "VisualScript"
const NATIVESCRIPT = "NativeScript"
const CSHARPSCRIPT = "C# Script"

const FIRST_BUTTON_PATH = "discord_presence/first_button"
const SECOND_BUTTON_PATH = "discord_presence/second_button"
const TIME_CHECKBOX_PATH = "discord_presence/settings/change_time_per_screen"

var _current_script_name: String
var _current_scene_name: String
var _current_editor_name: String
var _previous_script_name: String
var _previous_scene_name: String
var _previous_editor_name: String
var _previous_details: String
var _previous_large_image_text: String
var _is_reconnecting = false
var _reconnect_timer: Timer
var _is_ready = false
var _change_time_per_screen = false

var application_id: int = 928212232213520454
var rpc: DiscordRPC = null
var presence: RichPresence

const ASSETNAMES = {
	_2D: "2d",
	_3D: "3d",
	SCRIPT: "script",
	ASSETLIB: "assetlib",
	"LOGO_LARGE": "logo_vertical_color",
	"LOGO_SMALL": "icon_color",
}

func debug_print(string: String):
	if DEBUG:
		print(string)


func _enter_tree() -> void:
	_reconnect_timer = Timer.new()
	_reconnect_timer.one_shot = true
	_reconnect_timer.connect("timeout", self, "_on_reconnect_timer_timeout")
	_reconnect_timer.wait_time = RECONNECT_DURATION
	add_child(_reconnect_timer)

	connect("main_screen_changed", self, "_on_main_scene_changed")
	connect("scene_changed", self, "_on_scene_changed")
	get_editor_interface().get_script_editor().connect("editor_script_changed", self, "_on_editor_script_changed")

	if not rpc:
		_init_discord_rpc()

	_add_custom_settings()


func _exit_tree() -> void:
	disconnect("main_screen_changed", self, "_on_main_scene_changed")
	disconnect("scene_changed", self, "_on_scene_changed")
	get_editor_interface().get_script_editor().disconnect("editor_script_changed", self, "_on_editor_script_changed")

	if is_instance_valid(_reconnect_timer):
		_reconnect_timer.queue_free()

	if rpc and is_instance_valid(rpc):
		_destroy_discord_rpc()

	if presence:
		presence = null



func disable_plugin() -> void:
	if rpc and is_instance_valid(rpc):
		_destroy_discord_rpc()

	if presence:
		presence = null


func _on_reconnect_timer_timeout():
	_is_reconnecting = false
	if rpc and is_instance_valid(rpc):
		if not rpc.is_connected_to_client() and rpc.status != DiscordRPC.CONNECTING:
			rpc.establish_connection(application_id)


func _try_to_reconnect():
	if not _is_reconnecting and is_instance_valid(_reconnect_timer):
		# Not currently reconnecting so, start timer to wait to reconnect
		debug_print("Trying to reconnect after %ss" % RECONNECT_DURATION)
		_is_reconnecting = true
		_reconnect_timer.start()


func _on_rpc_error(err) -> void:
	if typeof(err) == TYPE_INT and err == DiscordRPC.ERR_CLIENT_NOT_FOUND:
		debug_print("Discord client not found")
		_is_ready = false
		_try_to_reconnect()

	elif typeof(err) == TYPE_STRING:
		debug_print("Got RPC Error String: " + err)


func _init_discord_rpc() -> void:
	debug_print("Initializing DiscordRPC")
	rpc = DiscordRPC.new()
	rpc.connect("rpc_error", self, "_on_rpc_error")
	add_child(rpc)
	rpc.connect("rpc_ready", self, "_on_rpc_ready")
	rpc.connect("rpc_closed", self, "_on_rpc_closed")
	rpc.establish_connection(application_id)


func _destroy_discord_rpc() -> void:
	if rpc and is_instance_valid(rpc):
		rpc.shutdown()
		rpc.queue_free()


func _on_rpc_ready(user: Dictionary):
	_is_ready = true
	debug_print("Connected to DiscordRPC")
	if presence != null:
		if rpc and is_instance_valid(rpc) and rpc.is_connected_to_client():
			_update(true)
		return
	_init_presence()


func _on_rpc_closed():
	_try_to_reconnect()


func _init_presence(dont_init := false) -> void:
	var is_null = false

	if presence != null and dont_init:
		# Dont reset the presence if dont_inti is true
		return
	elif presence == null:
		is_null = true

	presence = RichPresence.new()

	# Initial Presence Details
	presence.details = "In Godot Editor"
	presence.state = "Project: %s" % ProjectSettings.get_setting("application/config/name")
	presence.start_timestamp = OS.get_unix_time()
	presence.large_image_key = ASSETNAMES.LOGO_LARGE
	presence.large_image_text = "Working on a Godot project"

	if ProjectSettings.has_setting(FIRST_BUTTON_PATH + "/label") and ProjectSettings.has_setting(FIRST_BUTTON_PATH + "/url"):
		var label = ProjectSettings.get_setting(FIRST_BUTTON_PATH + "/label")
		var url = ProjectSettings.get_setting(FIRST_BUTTON_PATH + "/url")
		if label != "" and url != "":
			presence.first_button = RichPresenceButton.new(label, url)

	if ProjectSettings.has_setting(SECOND_BUTTON_PATH + "/label") and ProjectSettings.has_setting(SECOND_BUTTON_PATH + "/url"):
		var label = ProjectSettings.get_setting(SECOND_BUTTON_PATH + "/label")
		var url = ProjectSettings.get_setting(SECOND_BUTTON_PATH + "/url")
		if label != "" and url != "":
			presence.second_button = RichPresenceButton.new(label, url)

	if ProjectSettings.has_setting(TIME_CHECKBOX_PATH):
		var change_time_per_screen = ProjectSettings.get_setting(TIME_CHECKBOX_PATH)
		_change_time_per_screen = change_time_per_screen


	if is_null and rpc and is_instance_valid(rpc) and rpc.is_connected_to_client():
		rpc.get_module("RichPresence").update_presence(presence)


func _on_editor_script_changed(script: Script) -> void:
	if script:
		if _current_editor_name != SCRIPT:
			return
		_current_script_name = script.get_path().get_file()
		debug_print("Editor script changed: " + _current_script_name)
		_update()


func _on_main_scene_changed(screen_name: String) -> void:
	_current_editor_name = screen_name
	debug_print("Main scene changed: " + _current_editor_name)

	var script = get_editor_interface().get_script_editor().get_current_script()
	if script != null:
		_current_script_name = script.get_path().get_file()

	_update()


func _on_scene_changed(screen_root: Node) -> void:
	if is_instance_valid(screen_root):
		_current_scene_name = screen_root.filename.get_file()
		debug_print("Scene changed: " + _current_scene_name)
		_update()


func _update(send_previous := false) -> void:
	var just_started = false
	var should_update = false

	var is_current_in_scene_editors = true if _current_editor_name in SCENE_EDITORS else false
	var is_previous_in_scene_editors = true if _previous_editor_name in SCENE_EDITORS else false

	if _current_editor_name != _previous_editor_name:
		if is_current_in_scene_editors:
			# Currently in 2d or 3d editor

			# Get the name of the currently opened scene
			var scene = get_editor_interface().get_edited_scene_root()
			if scene:
				_current_scene_name = scene.filename.get_file()

			if is_previous_in_scene_editors:
				# Previous was also 2d or 3d
				should_update = false
			else:
				# Previous was not 2d or 3d
				should_update = true


	if is_current_in_scene_editors and is_previous_in_scene_editors:
		if _current_scene_name != _previous_scene_name:
			just_started = true

	_init_presence(not send_previous)
	presence.small_image_key = ASSETNAMES.LOGO_SMALL
	presence.small_image_text = "Godot Engine"
	if _current_editor_name in ASSETNAMES:
		presence.large_image_key = ASSETNAMES[_current_editor_name]
	else:
		presence.large_image_key = ASSETNAMES.LOGO_SMALL

	match _current_editor_name:
		_2D:
			presence.details = "Editing %s" % _current_scene_name
			presence.large_image_text = "In 2D editor"

		_3D:
			presence.details = "Editing %s" % _current_scene_name
			presence.large_image_text = "In 3D editor"

		SCRIPT:
			var script_type = SCRIPT
			presence.details = "Editing %s" % _current_script_name

			if _current_script_name != _previous_script_name or _current_editor_name != _previous_editor_name:
				# Script was changed or editor was changed to script editor
				just_started = true

			var extension = _current_script_name.get_extension().to_lower()
			# Find the type of the script based on the extension
			match extension:
				"gd":
					script_type = GDSCRIPT
					presence.large_image_key = "gdscript"
				"vs":
					script_type = VISUALSCRIPT
					presence.large_image_key = "visualscript"
				"gdns":
					script_type = NATIVESCRIPT
					presence.large_image_key = "nativescript"
				"cs":
					script_type = CSHARPSCRIPT
					presence.large_image_key = "csharpscript"

			if script_type == SCRIPT:
				# Some other type of script file
				presence.large_image_key = "script"

			presence.large_image_text = "Editing a " + script_type + " file"

		ASSETLIB:
			presence.details = "Browsing Asset Libary"
			presence.large_image_text = "Browsing Asset Library"
			just_started = true
		_:
			presence.details = "In %s editor" % _current_editor_name
			presence.large_image_text = "In %s editor" % _current_editor_name


	if just_started or should_update:
		if not send_previous or presence.start_timestamp == 0:
			if _change_time_per_screen:
				presence.start_timestamp = OS.get_unix_time()
		should_update = true

	if presence.details != _previous_details or presence.large_image_text != _previous_large_image_text:
		should_update = true


	if (send_previous or should_update) and _is_ready:
		debug_print("Updating presence. Client connected = " + str(rpc.is_connected_to_client()))
		if rpc and is_instance_valid(rpc):
			if rpc.is_connected_to_client():
				debug_print("Updated presence successfully")
				rpc.get_module("RichPresence").update_presence(presence)
			else:
				# Try to reconnect to the client
				_try_to_reconnect()

	_previous_editor_name = _current_editor_name
	_previous_scene_name = _current_scene_name
	_previous_script_name = _current_script_name
	_previous_details = presence.details
	_previous_details = presence.large_image_text


func _add_custom_settings():
	_add_custom_project_setting(FIRST_BUTTON_PATH + "/label", "Godot Engine", TYPE_STRING, PROPERTY_HINT_PLACEHOLDER_TEXT, "The label for the First Button of Discord Status")
	_add_custom_project_setting(FIRST_BUTTON_PATH + "/url", "https://godotengine.org", TYPE_STRING, PROPERTY_HINT_PLACEHOLDER_TEXT, "The URL for the First Button of Discord Status")

	_add_custom_project_setting(SECOND_BUTTON_PATH + "/label", "", TYPE_STRING, PROPERTY_HINT_PLACEHOLDER_TEXT, "The label for the Second Button of Discord Status")
	_add_custom_project_setting(SECOND_BUTTON_PATH + "/url", "", TYPE_STRING, PROPERTY_HINT_PLACEHOLDER_TEXT, "The URL for the Second Button of Discord Status")

	_add_custom_project_setting(TIME_CHECKBOX_PATH, false, TYPE_BOOL, PROPERTY_HINT_PLACEHOLDER_TEXT, "Whether to update the timer for each screen in the Editor")

	var error: int = ProjectSettings.save()
	if error: push_error("Encountered error %d when trying to add custom button settings to ProjectSettings." % error)


func _add_custom_project_setting(_name: String, default_value, type: int, hint: int = PROPERTY_HINT_NONE, hint_string: String = "") -> void:
	if ProjectSettings.has_setting(_name): return

	var setting_info: Dictionary = {
		"name": _name,
		"type": type,
		"hint": hint,
		"hint_string": hint_string
	}

	ProjectSettings.set_setting(_name, default_value)
	ProjectSettings.add_property_info(setting_info)
	ProjectSettings.set_initial_value(_name, default_value)


func _remove_custom_settings():
	_remove_custom_project_setting(FIRST_BUTTON_PATH + "/label")
	_remove_custom_project_setting(FIRST_BUTTON_PATH + "/url")
	_remove_custom_project_setting(SECOND_BUTTON_PATH + "/label")
	_remove_custom_project_setting(SECOND_BUTTON_PATH + "/url")
	_remove_custom_project_setting(TIME_CHECKBOX_PATH)
	var error: int = ProjectSettings.save()
	if error: push_error("Encountered error %d when trying to remove custom button settings from ProjectSettings." % error)


func _remove_custom_project_setting(name: String) -> void:
	if !ProjectSettings.has_setting(name): return
	ProjectSettings.set_setting(name, null)
