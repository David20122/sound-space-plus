extends SpinBox

var ov

func upd():
	if Rhythia.mod_hardrock:
		Rhythia.edge_drift = ((value + 1) * 1.6) - 1
	else:
		Rhythia.edge_drift = ov

func _process(_d):
	if value != Rhythia.edge_drift: upd()

func _on_Rhythia_mods_changed():
	upd()

func _ready():
	ov = value
	value = Rhythia.edge_drift
	connect("changed", self, "upd")
	Rhythia.connect("mods_changed", self, "_on_Rhythia_mods_changed")
