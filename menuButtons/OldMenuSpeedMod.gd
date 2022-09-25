extends ReferenceRect

onready var mmm:Button = $MMM
onready var mm:Button = $MM
onready var m:Button = $M
onready var normal:Button = $Normal
onready var p:Button = $P
onready var pp:Button = $PP
onready var ppp:Button = $PPP
onready var pppp:Button = $PPPP
onready var custom:Button = $Custom

func on_button_changed(state:bool,selectedSpeed:int):
	if state: SSP.mod_speed_level = selectedSpeed

func _ready():
	mmm.pressed = SSP.mod_speed_level == Globals.SPEED_MMM
	mm.pressed = SSP.mod_speed_level == Globals.SPEED_MM
	m.pressed = SSP.mod_speed_level == Globals.SPEED_M
	normal.pressed = SSP.mod_speed_level == Globals.SPEED_NORMAL
	p.pressed = SSP.mod_speed_level == Globals.SPEED_P
	pp.pressed = SSP.mod_speed_level == Globals.SPEED_PP
	ppp.pressed = SSP.mod_speed_level == Globals.SPEED_PPP
	pppp.pressed = SSP.mod_speed_level == Globals.SPEED_PPPP
	custom.pressed = SSP.mod_speed_level == Globals.SPEED_CUSTOM
	
	mmm.connect("toggled",self,"on_button_changed",[Globals.SPEED_MMM])
	mm.connect("toggled",self,"on_button_changed",[Globals.SPEED_MM])
	m.connect("toggled",self,"on_button_changed",[Globals.SPEED_M])
	normal.connect("toggled",self,"on_button_changed",[Globals.SPEED_NORMAL])
	p.connect("toggled",self,"on_button_changed",[Globals.SPEED_P])
	pp.connect("toggled",self,"on_button_changed",[Globals.SPEED_PP])
	ppp.connect("toggled",self,"on_button_changed",[Globals.SPEED_PPP])
	pppp.connect("toggled",self,"on_button_changed",[Globals.SPEED_PPPP])
	custom.connect("toggled",self,"on_button_changed",[Globals.SPEED_CUSTOM])
