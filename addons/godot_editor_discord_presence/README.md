Godot Editor Discord Presence
=========================================
###### (Get it from Godot Asset Library - Coming soon)


### Shows what you are doing in the Godot Editor as your Discord presence.

> Supports Windows, Linux and OSX

<img alt="Godot3" src="https://img.shields.io/badge/-Godot >= 3.2.2-478CBF?style=for-the-badge&logo=godotengine&logoWidth=20&logoColor=white" />
<br>


<img src="https://cdn.discordapp.com/attachments/360062738615107605/928505174375419906/plugin_icon.png" height="400">


Features
--------------

- Updates the Discord presence in real-time
- Has two customizable URL buttons
- Supports showing scripts like GDScript, VisualScript, NativeScript and CSharpScript
- Automatically reconnects to the Discord client
- Two modes for updating timestamp (start of the project vs whenever the screen changes)


Automatic Installation
--------------

Simply install and enable from the `AssetLib` in the Godot Editor. You might need to restart the Godot Editor once the plugin is installed.


Manual Installation
--------------

This is a regular plugin for Godot.
Copy the contents of `addons/godot_editor_discord_presence/` into the `res://addons/godot_editor_discord_presence/` folder which is in your project directory. You might need to restart the Godot Editor once the plugin is installed. Then goto `ProjectSettings` and activate it in the `Plugins` tab. 

**Optional:** To exclude the plugin when exporting your project, you can add `addons/godot_editor_discord_presence/*` to the `Filters to exclude files/folders from project` in the Export settings.

<img src="https://cdn.discordapp.com/attachments/360062738615107605/928504347120242688/unknown.png" height="300">

### Customizing the buttons

Once the plugin is enabled, close and open `ProjectSettings`. Now you can customize the two buttons by editing the values in the `Discord Presence` section. Then to apply the changes, disable and enable the plugin.

To hide a certain button, simply set the label to an empty string.

<img src="https://cdn.discordapp.com/attachments/360062738615107605/937919245277360218/unknown.png" height="400">

### Customizing the timestamp mode

Once the plugin is enabled, close and open `ProjectSettings`. Now you can customize the timestamp mode by editing the toggle value in the `Settings` section in `Discord Presence` section. Then to apply the changes, disable and enable the plugin.

If `Change time per screen` is disabled (default) the timestamp on the Discord presence will be updated at the start of the project. If enabled, the timestamp will be updated whenever the screen in Godot changes (e.g when you open a new scene, script, etc).


Contributing
-----------

This plugin is a non-profit project developped by voluntary contributors.


Third Party
-----------
This plugin uses [Discord-RPC-GDScript](https://github.com/Abdera7mane/Discord-RPC-GDScript) and [Godot-UnixSocket](https://github.com/Abdera7mane/Godot-UnixSocket) by [Abdera7mane](https://github.com/Abdera7mane)

### Support the project development
<a href="https://www.buymeacoffee.com/3ddelano" target="_blank"><img height="41" width="174" src="https://cdn.buymeacoffee.com/buttons/v2/default-red.png" alt="Buy Me A Coffee" width="150" ></a>
<br>
Want to support in other ways? Contact me on Discord: `@3ddelano#6033`

For doubts / help / bugs / problems / suggestions do join: [3ddelano Cafe](https://discord.gg/FZY9TqW)