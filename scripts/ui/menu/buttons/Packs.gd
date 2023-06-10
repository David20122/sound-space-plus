extends VBoxContainer

func _ready():
	for n in SSP.installed_packs:
		var l:HBoxContainer = $Pack.duplicate()
		add_child(l)
		l.visible = true
		l.setup(n[0],n[1])
	
	$Import.raise()
	$New.raise()
	$Dir.raise()
