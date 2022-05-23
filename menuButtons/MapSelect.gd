extends ReferenceRect

func upd(_s=null):
	if SSP.selected_song:
		$Mods.visible = true
		$EndInfo.visible = true
		$Run.disabled = SSP.selected_song.is_broken
		$PreviewMusic.disabled = SSP.selected_song.is_broken
		$Convert.disabled = $Convert.debounce or SSP.selected_song.converted or SSP.selected_song.is_broken or SSP.selected_song.songType == Globals.MAP_SSPM

func _ready():
	SSP.connect("selected_song_changed",self,"upd")
	if !SSP.selected_song:
		$Mods.visible = false
		$EndInfo.visible = false
		$Run.disabled = true
		$PreviewMusic.disabled = true
		$Convert.disabled = true
	else: upd()
