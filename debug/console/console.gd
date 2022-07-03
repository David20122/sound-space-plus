extends Panel

enum PRINT_TYPE {INFO,WARN,ERROR,RUN}

#var CloseButton# = $Close
#var RunButton# = $Run
#var TextHolder# = $Holder/Control
#var ScrollHolder# = $Holder
#var CommandBar# = $CommandBar
var LastLabel# = $Holder/Control/Label
#var Scroller# = ScrollHolder.get_v_scrollbar()

var debug = ProjectSettings.get_setting("application/config/enable_debug_features")
var console_open = false

onready var CloseButton = $Close
onready var RunButton = $Run
onready var TextHolder = $Holder/Control/Label
onready var DisplayText = get_node("../Text")
onready var ScrollHolder = $Holder
onready var CommandBar = $CommandBar
onready var Scroller = ScrollHolder.get_v_scrollbar()
#onready var MainViewport = get_node("../Center/Contain/Viewport")

var PrintedHeight = 0
var HistoryPosition = -1
var current = ""

# stuff
func consolePrint(text,kind=PRINT_TYPE.INFO):
	match kind:
		PRINT_TYPE.WARN:
			text = "[color=#ff6]%s[/color]" % text
		PRINT_TYPE.ERROR:
			text = "[color=#f66]%s[/color]" % text
		PRINT_TYPE.RUN:
			text = "[color=#a6fcff]%s[/color]" % text
		_:
			text = "[color=#ccc]%s[/color]" % text
	
	TextHolder.bbcode_text += "\n" + text
	DisplayText.bbcode_text += "\n" + text
	

func clear():
	TextHolder.bbcode_text = (
		"[color=#6f9][ Console Cleared ][/color]\n" +
		"[color=#77f][url=https://www.youtube.com/watch?v=dQw4w9WgXcQ]Console manual[/url][/color]"
	)


func openConsole():
	if not self.debug: return
#	get_tree().paused = true
	visible = true
	CommandBar.grab_focus()
#	MainViewport.gui_disable_input = true
	self.console_open = true
	CommandBar.text = CommandBar.text.rstrip("\\")
	get_parent().raise()

func close(_ct=null):
	get_tree().paused = false
	visible = false
#	MainViewport.gui_disable_input = false
	self.console_open = false
	rect_position = Vector2(0,0)
	CommandBar.release_focus()

func history_down():
	CommandBar.grab_focus()
	if HistoryPosition == -1: return
	HistoryPosition -= 1
	if HistoryPosition == -1: CommandBar.text = current
	else: CommandBar.text = Debug.history[HistoryPosition]
	CommandBar.caret_position = CommandBar.text.length()
	searchResults.clear()

func history_up():
	CommandBar.grab_focus()
	if HistoryPosition == -1: current = CommandBar.text
	if HistoryPosition + 2 > Debug.history.size(): return
	HistoryPosition += 1
	CommandBar.text = Debug.history[HistoryPosition]
	CommandBar.caret_position = CommandBar.text.length()
	searchResults.clear()

func commandCheck(id:String,_args):
	if id == "clear":
		clear()
		Debug.history.insert(0,"clear")
		return

func runTypedCommand(_content=""):
	HistoryPosition = -1
	current = ""
	var commandString = CommandBar.text
	CommandBar.text = ""
	Debug.runTypedCommand(commandString)
	

var searchResults = []

func searchCommands(text:String):
	searchResults.clear()
	for n in Debug.registeredCommands.keys():
		if n.begins_with(text):
			searchResults.append(n)

func setDisplayTextEnabled(args:Array):
	if args.size() == 0:
		Debug.consolePrint("argument 1 must be a boolean",Debug.PRINT_TYPE.ERROR)
		return
	var text:String = args[0]
	if text == "true" or text == "1": DisplayText.visible = true
	elif text == "false" or text == "0": DisplayText.visible = false
	else: Debug.consolePrint("argument 1 must be a boolean",Debug.PRINT_TYPE.ERROR)


var active_toasts = []

func show_toast(type:int,text:String,time=4.0):
	var frame:ColorRect
	match type:
		PRINT_TYPE.INFO: frame = $Toasts/Normal.duplicate()
		PRINT_TYPE.WARN:
			frame = $Toasts/Warning.duplicate()
			if time == null: time = 10.0
		PRINT_TYPE.ERROR:
			frame = $Toasts/Error.duplicate()
			if time == null: time = 14.0
		_: frame = $Toasts/Notice.duplicate()
	if time == null: time = 4.0
	get_node("../DebugToastHolder").add_child(frame)
	frame.get_node("Label").text = text
#	frame.time = time
	frame.visible = true
	yield(get_tree().create_timer(time),"timeout")
	frame.queue_free()
#	Debug.consolePrint('Displaying toast with text "%s"' % text)


func toastCommand(args:Array):
	if args.size() == 0:
		Debug.consolePrint("argument 1 must be an integer",Debug.PRINT_TYPE.ERROR)
		return
	if args.size() < 2:
		Debug.consolePrint("argument 2 must be a string",Debug.PRINT_TYPE.ERROR)
		return
		
	var kind:String = args[0]
	var text:String = args[1]
	if !kind.is_valid_integer():
		Debug.consolePrint("argument 0 must be an integer",Debug.PRINT_TYPE.ERROR)
		return
	
	show_toast(kind.to_int(),text)

func _process(delta):
	if Input.is_action_just_pressed("console"):
		if self.debug and Input.is_key_pressed(KEY_SHIFT):
			DisplayText.visible = !DisplayText.visible
		else:
			if visible: close()
			else: openConsole()
			searchResults.clear()
	if CommandBar.has_focus():
		if Input.is_action_just_pressed("ui_up"): history_up()
		if Input.is_action_just_pressed("ui_down"): history_up()
		if Input.is_action_just_pressed("ui_focus_next"):
			if searchResults.size() != 0:
				if CommandBar.text == searchResults[0]:
					if Input.is_key_pressed(KEY_SHIFT):
						 searchResults.push_front(searchResults.pop_back())
					else:
						 searchResults.append(searchResults.pop_front())
					CommandBar.text = searchResults[0]
					CommandBar.caret_position = CommandBar.text.length()
					return
			searchCommands(CommandBar.text)
			if searchResults.size() == 0: return
			CommandBar.text = searchResults[0]
			CommandBar.caret_position = CommandBar.text.length()

func _ready():
	visible = false
	DisplayText.visible = self.debug
	Debug.registerCommand("conhud",{
		type = Debug.CMD_TYPE.CALL,
		node = self,
		funcName = "setDisplayTextEnabled",
		protected = false,
		persist = true
	})
	Debug.registerCommand("toast",{
		type = Debug.CMD_TYPE.CALL,
		node = self,
		funcName = "toastCommand",
		protected = false,
		persist = true
	})
	TextHolder.connect("meta_clicked",OS,"shell_open")
	Debug.connect("command_executed",self,"commandCheck")
	RunButton.connect("pressed",self,"runTypedCommand")
	CloseButton.connect("pressed",self,"close")
	CommandBar.connect("text_entered",self,"runTypedCommand")
	Debug.connect("console_print",self,"consolePrint")
	Debug.connect("toast",self,"show_toast")
