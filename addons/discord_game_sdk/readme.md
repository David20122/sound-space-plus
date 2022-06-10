# Godot-Discord-Game-SDK 🥏🎶

> **Godot Discord Game SDK integration using GDNative.** Supports 💰Windows & 🐧Linux.

## Getting Started
1. Download the [example project](https://github.com/samsface/godot-discord-game-sdk/archive/refs/heads/master.zip).
1. Download the Discord Game SDK following the offical [Discord Game SDK documenation](https://discord.com/developers/docs/game-sdk/sdk-starter-guide) and extract any .so, .dll or .dylib files into the sample project's addons/discord_game_sdk directory.
3. Start the sample project! The Godot API is verbatim almost to the offical API so just follow the offical documenation.

### Or checkout this little tutorial on getting started:

[![Watch the video](https://img.youtube.com/vi/vHxXwpoLVGU/0.jpg)](https://www.youtube.com/watch?v=vHxXwpoLVGU)

## Snippets

### Updating activity

```gdscript
func update_activity() -> void:
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_state("Reached: 2-2")
	activity.set_details("Loadout: grenade + rail gun")

	var assets = activity.get_assets()
	assets.set_large_image("zone2")
	assets.set_large_text("ZONE 2 WOOO")
	assets.set_small_image("capsule_main")
	assets.set_small_text("ZONE 2 WOOO")

	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		push_error(result)
```

### Create lobby

```gdscript
func create_lobby():
	var transaction := Discord.lobby_manager.get_lobby_create_transaction()

	transaction.set_capacity(2)
	transaction.set_type(Discord.LobbyType.Private)
	transaction.set_locked(false)

	var result = yield(Discord.lobby_manager.create_lobby(transaction), "result")
	if result.result != Discord.Result.Ok:
		push_error(result.result)
		return

	var lobby = result.data	
	Discord.lobby_manager.send_lobby_message(lobby.get_id(), "hello people!")
```
