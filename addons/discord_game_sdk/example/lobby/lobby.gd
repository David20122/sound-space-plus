extends Control

var lobby_id_
var secret_
var game_state_:GameState

func _ready() -> void:
	game_state_ = get_parent().game_state_
	Discord.discore_core_.connect("log", self, "log_")
	Discord.activity_manager.connect("activity_join", self, "activity_join_")
	Discord.activity_manager.connect("activity_invite", self, "activity_invite_")
	Discord.activity_manager.connect("activity_join_request", self, "activity_join_request_")
	Discord.lobby_manager.connect("lobby_message", self, "lobby_message_")
	Discord.lobby_manager.connect("member_connect", self, "member_connect_")
	
	var res = Discord.activity_manager.register_command("/media/sam/adffc9be-fe94-4c6b-87db-cca9cb566739/work/godot-discord/app/export/game.x86_64")
	if res != Discord.Result.Ok:
		push_error(res)

func log_(message) -> void:
	pass
	#$debug.text += message + "\n"

func activity_join_(secret:String) -> void:
	var result = yield(Discord.lobby_manager.connect_lobby_with_activity_secret(secret), "result")
	if result.result == Discord.Result.Ok:
		lobby_id_ = result.data.get_id()
		refresh_members(lobby_id_)
		
func refresh_members(lobby_id) -> void:
	game_state_.members.clear()

	var member_users = Discord.lobby_manager.get_all_member_users(lobby_id)
	for user in member_users:
		var member := Member.new()
		member.id = user.get_id()
		member.username = user.get_username()
		game_state_.members[member.id] = member
	
	game_state_.emit_signal("members_changed")
	
func activity_invite_() -> void:
	pass

func activity_join_request_() -> void:
	pass

func lobby_message_(lobby_id:int, user_id:int, message:String) -> void:
	var chat_mesasge := ChatMessage.new()
	chat_mesasge.member_id = user_id
	chat_mesasge.message = message
	game_state_.chat.push_back(chat_mesasge)
	game_state_.emit_signal("chat_changed")

func member_connect_(lobby_id:int, user_id:int) -> void:
	refresh_members(lobby_id)

func update_activity_() -> void:
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_state("Reached: 2-2")
	activity.set_name("NAME NAME NAME")
	activity.set_details("Loadout: grenade + rail gun")
	var assets = activity.get_assets()
	assets.set_large_image("zone2")
	assets.set_large_text("ZONE 2 WOOO")
	assets.set_small_image("capsule_main")
	assets.set_small_text("ZONE 2 WOOO")
	var secrets = activity.get_secrets()
	secrets.set_join(str(lobby_id_) + ":" + secret_)
	var party = activity.get_party()
	party.set_id(str(lobby_id_))
	party.get_size().set_current_size(1)
	party.get_size().set_max_size(6)

	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		push_error(result)
		
	invite_to_join_()

func invite_to_join_() -> void:
	var result = yield(Discord.overlay_manager.open_activity_invite(Discord.ActivityActionType.Join), "result").result
	if result != Discord.Result.Ok:
		push_error(result)

func send_message(new_text:String):
	var result = yield(Discord.lobby_manager.send_lobby_message(lobby_id_, new_text), "result").result
	if result != Discord.Result.Ok:
		push_error(result)

func _on_create_game_pressed():
	var transaction := Discord.lobby_manager.get_lobby_create_transaction()

	transaction.set_capacity(2)
	transaction.set_type(Discord.LobbyType.Private)
	transaction.set_locked(false)

	var result = yield(Discord.lobby_manager.create_lobby(transaction), "result")
	if result.result != Discord.Result.Ok:
		push_error(result.result)
		return

	var lobby = result.data
	lobby_id_ = lobby.get_id()
	secret_ = lobby.get_secret()

	update_activity_()
