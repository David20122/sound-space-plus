extends ColorRect

var target:bool = false
var fade:float = 0

func start_download():
#	target = true
	$Cancel.grab_focus()
	visible = true
	fade = 1

func end_download(v:bool=false):
	$Cancel.release_focus()
	visible = v

func _process(delta):
	var amt:float = Online.mapdl_hr.get_downloaded_bytes()
	var total:float = Online.mapdl_bs
	if total > 0:
		$Label.text = "Downloading map...\n%.02f%%" % [(amt/total) * 100]

func _ready():
	SSP.connect("download_start",self,"start_download")
	SSP.connect("download_done",self,"end_download")
	pause_mode = PAUSE_MODE_PROCESS
	$Cancel.connect("pressed",Online,"cancel")

#func _process(delta):
#	if target && fade != 1:
#		fade = min(fade + (delta/0.35),1)
#		modulate = Color(1,1,1,fade)
#	elif !target && fade != 0:
#		fade = max(fade - (delta/0.35),0)
#		modulate = Color(1,1,1,fade)
#	visible = (fade != 0)
