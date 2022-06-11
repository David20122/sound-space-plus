extends ReferenceRect

func upd(_s=null):
	if SSP.selected_song:
		$ModsHolder.visible = true
		$ModsTitle.visible = true
		$EndInfo.visible = true
		$Info.visible = true
		$Hitboxes.visible = true
		$Run.disabled = SSP.selected_song.is_broken
#		$PreviewMusic.disabled = SSP.selected_song.is_broken
		$Convert.disabled = $Convert.debounce or SSP.selected_song.converted or SSP.selected_song.is_broken or SSP.selected_song.is_builtin or SSP.selected_song.songType == Globals.MAP_SSPM
		if !SSP.selected_song.is_builtin and SSP.selected_song.songType == Globals.MAP_SSPM:
			$Convert.visible = false
			$Difficulty.visible = true
		else:
			$Convert.visible = true
			$Difficulty.visible = false

func _ready():
	SSP.connect("selected_song_changed",self,"upd")
	if !SSP.selected_song:
		$ModsHolder.visible = false
		$ModsTitle.visible = false
		$Hitboxes.visible = false
		$EndInfo.visible = false
		$Info.visible = false
		$Run.disabled = true
#		$PreviewMusic.disabled = true
		$Convert.disabled = true
		$Convert.visible = true
		$Difficulty.visible = false
	else: upd()
