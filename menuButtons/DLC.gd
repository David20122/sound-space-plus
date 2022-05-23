extends VBoxContainer

func _ready():
	for n in SSP.installed_dlc:
		var l:Label = $Mod.duplicate()
		add_child(l)
		l.visible = true
		l.text = n + "*"
		l.modulate = Color("#ffaaee")
	for n in SSP.installed_mods:
		var l:Label = $Mod.duplicate()
		add_child(l)
		l.visible = true
		l.text = n
	$Dir.raise()
