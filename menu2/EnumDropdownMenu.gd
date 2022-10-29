extends MenuButton

export(Array,String) var options = []
export(String) var target
var current_sel:int

func on_pressed(i):
	SSP.set(target,i)


func _ready():
	current_sel = SSP.get(target)
	for i in range(options.size()):
		get_popup().add_check_item(options[i],i)
		if current_sel == i:
			get_popup().set_item_checked(i,true)
	get_popup().connect("id_pressed",self,"on_pressed")
