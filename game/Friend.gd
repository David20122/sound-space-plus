extends MeshInstance

var failed = false

onready var Game = get_node("../..")
onready var Spawn = get_node("..")

func does_state_apply(state:String):
	var hp = Game.energy
	match state:
		"done": return (Spawn.ms > get_node("../..").last_ms)
		"fail": return failed
		"givingup": return Input.is_action_pressed("give_up")
		"unpausing": return (Spawn.pause_state > 0)
		"paused": return (Spawn.pause_state != 0)
		"fullcombo": return (Game.misses == 0)
		"1hp": return (hp <= 1)
		"halfhp": return (hp <= (Game.max_energy)/2)
		"losthp": return (hp != (Game.max_energy))
		"normal": return true

var all_states:Array = [
	"done",
	"fail",
	"givingup",
	"unpausing",
	"paused",
	"fullcombo",
	"1hp",
	"halfhp",
	"losthp",
	"normal"
]
var states:Array = []
var textures:Array = []

var last_state = -1
func upd():
	if states.size() == 0: return
	for i in range(states.size()):
		if does_state_apply(states[i]):
			if i == last_state: return
			last_state = i
			get("material/0").albedo_texture = textures[i]
			return

func _process(delta):
	upd()

func _ready():
	for s in all_states:
		var tex = Globals.imageLoader.load_if_exists("user://friend/" + s)
		if tex:
			states.append(s)
			textures.append(tex)
	if states.size() == 0: visible = false
	upd()
	
	match SSP.friend_position:
		Globals.FRIEND_LOWER_RIGHT:
			return
		Globals.FRIEND_LOWER_LEFT:
			transform = get_node("../FriendLL").transform
		Globals.FRIEND_UPPER_LEFT:
			transform = get_node("../FriendUL").transform
		Globals.FRIEND_UPPER_RIGHT:
			transform = get_node("../FriendUR").transform
		Globals.FRIEND_FILL_GRID:
			transform = get_node("../FriendC").transform
			get("material/0").albedo_color.a = 0.1
			mesh.size = Vector2(3,3)
		Globals.FRIEND_BEHIND_GRID:
			transform = get_node("../FriendBG").transform
			get("material/0").albedo_color.a = 0.1
			mesh.size = Vector2(1,1)
