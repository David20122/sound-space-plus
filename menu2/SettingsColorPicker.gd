extends ColorPickerButton

export(String) var target

func upd():
	yield(get_tree(),"idle_frame")
	print(target, " ", color.to_html(color.a != 1), " WAUGH!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	SSP.set(target,color)

#func _process(_d):
#	if color != SSP.get(target): upd()
	
func _ready():
	color = SSP.get(target)
	connect("popup_closed",self,"upd")
