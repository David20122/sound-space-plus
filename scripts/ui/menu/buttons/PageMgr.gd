extends ColorRect

onready var pages:Array = [$Settings,$MapRegistry,$ContentMgr,$Credits]
onready var buttons:Array = [$SettingsBtn,$MapRegBtn,$ContentMgrBtn,$CreditsBtn]

func press(bi:int,q:bool=false):
	if !q: $Press.play()
	for i in range(pages.size()):
		pages[i].visible = i == bi
		buttons[i].pressed = i == bi

func _ready():
	for i in range(buttons.size()):
		buttons[i].connect("pressed",self,"press",[i])
	
	# If no maps are found, go to content manager
	if SSP.registry_song.items.size() == 0: press(2,true)
	else: press(1,true)
	
