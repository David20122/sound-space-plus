extends Node

enum PRINT_TYPE {INFO,WARN,ERROR,RUN}
enum TOAST_TYPE {INFO,WARN,ERROR,NOTICE}
enum CMD_TYPE {SIGNAL,CALL,ALIAS,VAR}
enum VAR_TYPE {STRING,INT,FLOAT,BOOL}

signal console_print
signal command_executed
signal toast

func consolePrint(text,type=PRINT_TYPE.INFO):
	emit_signal("console_print",text,type)

func toast(type:int,text:String,time=null):
	emit_signal("toast",type,text,time)

func concat(arr:Array) -> String:
	var s:String = ""
	var i = 0
	
	for v in arr:
		if i != 0: s += " "
		if v is String: s += v
		else: v += String(v)
		i += 1
	
	return s

var registeredCommands = {
	help = {
		type = CMD_TYPE.CALL,
		node = self,
		funcName = "help",
		protected = true,
		persist = true
	},
	clear = {
		type = CMD_TYPE.SIGNAL,
		protected = true,
		persist = true
	},
	helpme = {
		type = CMD_TYPE.ALIAS,
		target = "help",
		protected = true,
		persist = true
	},
	quit = {
		type = CMD_TYPE.CALL,
		node = self,
		funcName = "quit",
		protected = true,
		persist = true
	},
#	mainmenu = {
#		type = CMD_TYPE.CALL,
#		node = self,
#		funcName = "menuExit",
#		skipResults = true,
#		protected = true,
#		persist = true
#	},
}

var history = []

# Command Functions
func help(_args):
	var liststr = "Listing commands:"
	for cmd in registeredCommands:
		liststr += "\n- " + cmd
	consolePrint(liststr)

func quit(_args): get_tree().quit()

func _unregisterCommand(id:String):
	if registeredCommands.has(id):
		registeredCommands.erase(id)
#		consolePrint("command '%s' unregistered" % id)

func unregisterCommand(id:String,silent:bool=false):
	if registeredCommands.has(id):
		if registeredCommands[id].protected:
			if not silent: consolePrint("attempted to unregister protected command '%s'" % id,PRINT_TYPE.ERROR)
			return
		_unregisterCommand(id)

func registerCommand(id:String,data:Dictionary,overwrite:bool=true,persist:bool=false):
	if registeredCommands.has(id):
		if registeredCommands[id].has("protected") and registeredCommands[id].protected:
			consolePrint("attempted to overwrite protected command '%s'" % id,PRINT_TYPE.ERROR)
			return
		if not overwrite: return
	if not data.has("type"):
			consolePrint("could not register command '%s' (no type value)" % id,PRINT_TYPE.ERROR)
			return
	
	registeredCommands[id] = data
#	consolePrint("command '%s' registered" % id)

func unregisterAllCommands(keepPersist:bool = false):
	for id in registeredCommands.keys():
		if not (keepPersist and registeredCommands[id].has("persist")):
			unregisterCommand(id)

func runTypedCommand(commandString):
	if commandString == "":
		return
	consolePrint("> "+commandString,PRINT_TYPE.RUN)
	history.insert(0,commandString)
	var regex = RegEx.new()
	#regex.compile("\\S+(?=\\s|$)")
	regex.compile('(("(?!").*"(?!"))|\\S+)(?=\\s|$)')
	var results = regex.search_all(commandString)
	var cmdName = results[0].get_string()
	
	var stringResults = []
	for r in results:
		var s:String = r.get_string()
		if s.begins_with('"'): s.erase(0,1)
		if s.ends_with('"'): s.erase(s.length()-1,1)
		s = s.replace('""','"')
		stringResults.append(s)
	
	if registeredCommands.has(stringResults[0]):
		var cmd = registeredCommands[stringResults[0]]
		if cmd.type == CMD_TYPE.ALIAS:
			if not cmd.has("target") or not registeredCommands.has(cmd.target):
				consolePrint("failed to run command '%s' (broken alias)" % cmdName,PRINT_TYPE.ERROR)
				return
			else: cmd = registeredCommands[cmd.target]
		if cmd.type == CMD_TYPE.ALIAS:
			consolePrint("failed to run command '%s' (nested alias)" % cmdName,PRINT_TYPE.ERROR)
			return
		elif cmd.type == CMD_TYPE.SIGNAL:
			emit_signal("command_executed",stringResults.pop_front(),stringResults)
		elif cmd.type == CMD_TYPE.CALL:
			if not cmd.has("node") or not cmd.has("funcName") or cmd.node == null:
				consolePrint("failed to run command '%s' (broken call)" % cmdName,PRINT_TYPE.ERROR)
				return
			stringResults.pop_front()
			if cmd.has("skipResults") and cmd.skipResults == true: cmd.node.call(cmd.funcName)
			else: cmd.node.call(cmd.funcName,stringResults)
		elif cmd.type == CMD_TYPE.VAR:
			if !cmd.has("node") or !cmd.has("variable") or !cmd.has("varType") or cmd.node == null:
				consolePrint("failed to run command '%s' (broken var)" % cmdName,PRINT_TYPE.ERROR)
				return
			if stringResults.size() == 1:
				match cmd.varType:
					VAR_TYPE.BOOL:
						var current = cmd.node.get(cmd.variable)
						cmd.node.set(cmd.variable,!current)
						current = !current
						consolePrint("Toggling variable (new value: %s)" % current)
					VAR_TYPE.STRING: consolePrint("argument 1 must be a string" % cmdName,PRINT_TYPE.ERROR)
					VAR_TYPE.FLOAT: consolePrint("argument 1 must be a number" % cmdName,PRINT_TYPE.ERROR)
					VAR_TYPE.INT: consolePrint("argument 1 must be an integer" % cmdName,PRINT_TYPE.ERROR)
					_: consolePrint("invalid var type %s" % cmd.varType,PRINT_TYPE.ERROR)
			else:
				var text:String = stringResults[1]
				match cmd.varType:
					VAR_TYPE.BOOL:
						consolePrint("%s = %s" % [cmd.variable,text])
						if text == "true" or text == "1": cmd.node.set(cmd.variable,true)
						elif text == "false" or text == "0": cmd.node.set(cmd.variable,false)
						else: consolePrint("argument 1 must be a boolean",PRINT_TYPE.ERROR)
					VAR_TYPE.FLOAT:
						if text.is_valid_float(): cmd.node.set(cmd.variable,text.to_float())
						else: consolePrint("argument 1 must be a number",PRINT_TYPE.ERROR)
					VAR_TYPE.INT:
						if text.is_valid_integer(): cmd.node.set(cmd.variable,text.to_int())
						else: consolePrint("argument 1 must be an integer",PRINT_TYPE.ERROR)
					VAR_TYPE.STRING: cmd.node.set(cmd.variable,text)
					_: consolePrint("invalid var type %s" % cmd.varType,PRINT_TYPE.ERROR)
		
	else: 
		consolePrint("failed to run command '%s' (command does not exist)" % cmdName,PRINT_TYPE.ERROR)

func checkForBrokenCalls():
	for id in registeredCommands.keys():
		var cmd = registeredCommands[id]
		if cmd.type == CMD_TYPE.CALL:
			if cmd.has("node") and cmd.node == null:
				_unregisterCommand(id)

func _ready():
	get_tree().connect("tree_changed",self,"checkForBrokenCalls")
