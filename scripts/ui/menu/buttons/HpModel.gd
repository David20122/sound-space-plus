extends MenuButton

var meshes:Array = []
var current_sel:int


var names = [
	"Default - same as Sound Space", # HP_SOUNDSPACE
	"Old - 6 hp (10 on easy), regen 1 hp/hit" # HP_OLD
]
var namet = [ # Shown on the button
	"Default (Sound Space)",
	"Old (easier)"
]

func on_pressed(i):
	SSP.health_model = i
	on_model_selected(i)

func on_model_selected(model:int):
	text = namet[model]
	get_popup().set_item_checked(current_sel,false)
	for i in range(names.size()):
		if i == model:
			current_sel = i
			get_popup().set_item_checked(i,true)

func _ready():
	for i in range(names.size()):
		get_popup().add_check_item(names[i],i)
	get_popup().connect("id_pressed",self,"on_pressed")
	on_model_selected(SSP.health_model)
