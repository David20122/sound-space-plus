# Sound Space Plus

While you're here, join our discord in [here](https://discord.gg/ssp)

Support the game on [Patreon](https://www.patreon.com/soundspaceplus)

# Table of contents
(Stuff you will see in this README)

- [Downloading the game](#dl)
    - [Important info before Downloading](#dl-imp)
        - [Windows](#dl-win)
        - [Linux](#dl-penguin)
        - [Android](#dl-phone)
    - [Making SSP executable on Linux](#dl-linuxfix)
- [Troubleshooting](#tr)
- [User Folder location](#usr)
- [Updating the game](#upd)
- [Developer zone](#dev)

# Downloading and playing the game <a href="#dl-title" id="dl"/>

## IMPORTANT! <a href="#dl-main" id="dl-imp"/>

- There's no point in git cloning this repository.

  - Head to the [releases tab](https://github.com/Gapva/SSPReleases/releases) to Download this game.

- As of the Apr16 Update, Androids don't have a User Folder, this is temporary and will be changed in the future.

### For Windows users: <a href="#dl-main" id="dl-win"/>

- In [releases](https://github.com/Gapva/SSPReleases/releases), press on the `windows.zip` folder to download it

- Once downloaded, do the following:
  - Right click the folder and extract it to either a custom folder [RECOMMENDED] or the folder you downloaded to [NOT RECOMMENDED]. Alternatively, you can open the zip file and drag the contents inside to a custom folder.
  - Run SoundSpacePlus.exe to play this, easy I know.

### For Linux users: <a href="#dl-main" id="dl-penguin"/>

- In [releases](https://github.com/Gapva/SSPReleases/releases), press on the `linux.zip` folder to download it

- Once downloaded do the following:
  - If you have a GUI File Explorer:
    - In Downloads, right click and extract the files like on Windows OR open the zip and extract it
  - If you don't have a GUI File Explorer:
    - Download your game normally and `cd` to your Downloads folder (usually `cd ~/Downloads`)
    - Inside your downloads folder type: `mkdir SSP && unzip linux.zip -d SSP/` to make a SSP directory and unzip linux.zip to that directory (REMEMBER TO INSTALL THE UNZIP PACKAGE USING YOUR PACKAGE MANAGER!!!)
    
### For Android Users: <a href="#dl-main" id="dl-phone"/>

- Download gles2 on older devices, or gles3 on newer devices
- Install the apk on your phone

## If you can't execute your game on Linux <a href="#dl-trouble" id="dl-linuxfix"/>

- Open your terminal and do the following:
```bash
$ cd ~/DIRECTORY_OF_YOUR_SSP_FOLDER
$ sudo chmod +x SoundSpacePlus.x86_64
# Alternatively you can use
# sudo chmod 777 SoundSpacePlus.x86.64
```

# Troubleshooting <a href="#tlsh-title" id="tr"/>

As everything you download online, executing may or may not work.

- [WINDOWS ONLY] If the game closes by itself
  - Download and install [vc_redist](https://aka.ms/vs/17/release/vc_redist.x64.exe)
  - Open the game.
  - If your game still doesn't work, head to the [Discord](https://discord.gg/ssp) and head to the support channel.
  
  
# User folder location <a href="#usr-title" id="usr"/>

- Windows:

`%appdata%\SoundSpacePlus`

- Linux:

`~/.local/share/SoundSpacePlus`

- Android:

Currently not available (Apr16 update)

### Alternatively you can access the user folder if you go into settings and press User Folder

# Updating your game <a href="#upd-title" id="upd"/>

As the time goes, we all have the necessity to update what's old correct?

### Here's how you do it then.

- Head to the [latest version of the game](https://github.com/Gapva/SSPReleases/releases/latest) and Download it
- On the location where your folder is delete or replace every file inside it
  - Keep in mind that you <ins>**__DON'T__**</ins> lose your passes, replays or maps when update the game, those are located in the [user folder](#usr)
  - [Apr25 Update] Windows and Linux users now have an integrated auto-updater as of the Apr25 update. Android and MacOS auto-updaters will come soon. [Click here to access the latest releases with auto-updaters](https://github.com/krmeet/sound-space-plus/releases/latest)
- And you're done. You are now up-to-date.

# Development <a href="dev-title" id="dev"/>
After cloning the repository download the Discord Game SDK and put the following files into addons/discord_game_sdk:  
- `discord_game_sdk.dll`  
- `discord_game_sdk.dylib`  
- `discord_game_sdk.so` (__rename to `libdiscord_game_sdk.so`__)  
