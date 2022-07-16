extends MenuButton

var meshes:Array = []
var current_sel:int


var names = [
	"Default - extra scoring types", # GRADE_SSP
	"Legacy - same as the original game" # GRADE_LEGACY
]
var namet = [ # Shown on the button
	"Default (Sound Space+)",
	"Legacy (Sound Space)"
]

func on_pressed(i):
	SSP.grade_system = i
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
	on_model_selected(SSP.grade_system)
