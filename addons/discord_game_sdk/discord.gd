extends Node

enum Result {
	Ok = 0,
	ServiceUnavailable = 1,
	InvalidVersion = 2,
	LockFailed = 3,
	InternalError = 4,
	InvalidPayload = 5,
	InvalidCommand = 6,
	InvalidPermissions = 7,
	NotFetched = 8,
	NotFound = 9,
	Conflict = 10,
	InvalidSecret = 11,
	InvalidJoinSecret = 12,
	NoEligibleActivity = 13,
	InvalidInvite = 14,
	NotAuthenticated = 15,
	InvalidAccessToken = 16,
	ApplicationMismatch = 17,
	InvalidDataUrl = 18,
	InvalidBase64 = 19,
	NotFiltered = 20,
	LobbyFull = 21,
	InvalidLobbySecret = 22,
	InvalidFilename = 23,
	InvalidFileSize = 24,
	InvalidEntitlement = 25,
	NotInstalled = 26,
	NotRunning = 27,
	InsufficientBuffer = 28,
	PurchaseCanceled = 29,
	InvalidGuild = 30,
	InvalidEvent = 31,
	InvalidChannel = 32,
	InvalidOrigin = 33,
	RateLimited = 34,
	OAuth2Error = 35,
	SelectChannelTimeout = 36,
	GetGuildTimeout = 37,
	SelectVoiceForceRequired = 38,
	CaptureShortcutAlreadyListening = 39,
	UnauthorizedForAchievement = 40,
	InvalidGiftCode = 41,
	PurchaseError = 42,
	TransactionAborted = 43,
}

enum CreateFlags {
	Default = 0,
	NoRequireDiscord = 1,
}

enum ActivityType {
	Playing = 0,
	Streaming = 1,
	Listening = 2,
	Watching = 3,
}

enum ActivityActionType {
	Join = 1,
	Spectate,
};

enum LobbyType {
	Private = 1,
	Public,
};

class Proxy_:
	var object_to_proxy_

	func _init(object_to_proxy) -> void:
		object_to_proxy_ = object_to_proxy

	func call_(func_name, args := []):
		if not object_to_proxy_:
			return Result.InternalError
		
		return object_to_proxy_.callv(func_name, args)

	func callback_(func_name, args := []):
		if not object_to_proxy_:
			var result = DiscordResult.new()
			result.result = Result.InternalError
			result.call_deferred("emit_signal", "result", result)
			return result
		
		return object_to_proxy_.callv(func_name, args)

class User extends Proxy_:
	func _init(user:DiscordUser).(user) -> void:
		pass

	func get_id() -> int:
		return object_to_proxy_.get_id()

	func get_username() -> String:
		return object_to_proxy_.get_username()

class LobbyTransaction extends Proxy_:
	func _init(lobby_transaction:DiscordLobbyTransaction).(lobby_transaction) -> void:
		pass

	func set_type(type:int) -> int:
		return object_to_proxy_.set_type(type)
	
	func set_owner(owner_id:int) -> int:
		return object_to_proxy_.set_owner(owner_id)

	func set_capacity(capacity:int) -> int:
		return object_to_proxy_.set_capacity(capacity)

	func set_metadata(key:String, value:String) -> int:
		return object_to_proxy_.set_metadata(key, value)

	func delete_metadata(key:String) -> int:
		return object_to_proxy_.delete_metadata(key)

	func set_locked(locked:bool) -> int:
		return object_to_proxy_.set_locked(locked)

class Activity extends Proxy_:
	func _init().(DiscordActivity.new()) -> void:
		pass

	func set_type(value:int) -> void:
		object_to_proxy_.set_type(value)

	func set_application_id(value:int) -> void:
		object_to_proxy_.set_application_id(value)
	
	func set_name(value:String) -> void:
		object_to_proxy_.set_name(value)
	
	func set_state(value:String) -> void:
		object_to_proxy_.set_state(value)
	
	func set_details(value:String) -> void:
		object_to_proxy_.set_details(value)
	
	func get_assets() -> DiscordActivityAssets:
		return object_to_proxy_.get_assets()

	func get_secrets() -> DiscordActivitySecrets:
		return object_to_proxy_.get_secrets()

	func get_party() -> DiscordActivityParty:
		return object_to_proxy_.get_party()

	func get_timestamps() -> DiscordActivityTimestamps:
		return object_to_proxy_.get_timestamps()

class ActivityManager_ extends Proxy_:
	signal activity_join
	signal activity_invite
	signal activity_join_request

	func _init(activity_manager).(activity_manager) -> void:
		if activity_manager:
			activity_manager.connect("activity_join", self, "_on_activity_join")
			activity_manager.connect("activity_invite", self, "_on_activity_invite")
			activity_manager.connect("activity_join_request", self, "_on_activity_join_request")

	func _on_activity_join(secret:String) -> void:
		emit_signal("activity_join", secret)
	
	func _on_activity_invite() -> void:
		emit_signal("activity_invite")
	
	func _on_activity_join_request() -> void:
		emit_signal("activity_join_request")

	func register_command(string:String) -> int:
		return call_("register_command", [string])

	func clear_activity() -> DiscordResult:
		return callback_("clear_activity")

	func update_activity(activity:Activity) -> DiscordResult:
		return callback_("update_activity", [activity.object_to_proxy_])

class LobbyManager_ extends Proxy_:
	signal lobby_message
	signal member_connect

	func _init(lobby_manager).(lobby_manager) -> void:
		if lobby_manager:
			lobby_manager.connect("lobby_message", self, "_on_lobby_message")
			lobby_manager.connect("member_connect", self, "_on_member_connect")

	func _on_lobby_message(lobby_id:int, user_id:int, string:String) -> void:
		emit_signal("lobby_message", lobby_id, user_id, string)

	func _on_member_connect(lobby_id:int, user_id:int) -> void:
		emit_signal("member_connect", lobby_id, user_id)

	func connect_lobby_with_activity_secret(secret:String) -> DiscordResult:
		return callback_("connect_lobby_with_activity_secret", [secret])

	func get_lobby_create_transaction() -> LobbyTransaction:
		var transaction = DiscordLobbyTransaction.new()
		if call_("get_lobby_create_transaction", [transaction]) == Result.Ok:
			return LobbyTransaction.new(transaction)
		return null

	func update_activity(activity:Activity) -> DiscordResult:
		return callback_("update_activity", [activity.object_to_proxy_])
	
	func create_lobby(transaction:LobbyTransaction) -> DiscordResult:
		return callback_("create_lobby", [transaction.object_to_proxy_])

	func send_lobby_message(lobby_id:int, message:String) -> DiscordResult:
		return callback_("send_lobby_message", [lobby_id, message.to_utf8()])

	func get_member_count(lobby_id:int) -> int:
		return call_("get_member_count", [lobby_id])

	func get_member_user_id(lobby_id:int, member_count_idx:int) -> int:
		return call_("get_member_user_id", [lobby_id, member_count_idx])

	func get_member_user(lobby_id:int, user_id:int) -> User:
		var user = DiscordUser.new()
		var res = call_("get_member_user", [lobby_id, user_id, user])
		if res == Result.Ok:
			return User.new(user)
		return null

	func get_all_member_users(lobby_id:int) -> Array:
		var res := []
		for i in get_member_count(lobby_id):
			var user_id = get_member_user_id(lobby_id, i)
			var user = get_member_user(lobby_id, user_id)
			if user:
				res.push_back(user)
		return res
		
class OverlayManager_ extends Proxy_:
	func _init(overlay_manager).(overlay_manager) -> void:
		pass

	func open_activity_invite(activation_type:int) -> DiscordResult:
		return callback_("open_activity_invite", [activation_type])

var discore_core_:DiscordCore
var activity_manager:ActivityManager_
var lobby_manager:LobbyManager_
var overlay_manager:OverlayManager_

func _ready():
	# uncomment to test against a second canary discord client
	#if OS.has_feature("standalone"):
	#	OS.set_environment("DISCORD_INSTANCE_ID", "1")
	#else:
	#	OS.set_environment("DISCORD_INSTANCE_ID", "0")
	
	if ProjectSettings.get_setting("application/config/discord_rpc"):
		discore_core_ = DiscordCore.new()
		if discore_core_:
			discore_core_.create(978085646272983060, CreateFlags.NoRequireDiscord)
			
			activity_manager = ActivityManager_.new(discore_core_.get_activity_manager())
			lobby_manager = LobbyManager_.new(discore_core_.get_lobby_manager())
			overlay_manager = OverlayManager_.new(discore_core_.get_overlay_manager())
	
func _process(delta:float) -> void:
	if discore_core_:
		discore_core_.run_callbacks()
