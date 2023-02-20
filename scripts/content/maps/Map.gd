extends ResourcePlus
class_name Map

enum Difficulty { # LEGACY SUPPORT
	UNKNOWN,
	EASY,
	MEDIUM,
	HARD,
	LOGIC,
	TASUKETE
}
const DifficultyColours = { # LEGACY SUPPORT
	Difficulty.UNKNOWN: Color("#ffffff"),
	Difficulty.EASY: Color("#00ff00"),
	Difficulty.MEDIUM: Color("#ffb800"),
	Difficulty.HARD: Color("#ff0000"),
	Difficulty.LOGIC: Color("#d76aff"),
	Difficulty.TASUKETE: Color("#36304f"),
}
const DifficultyNames = {
	Difficulty.UNKNOWN: "N/A",
	Difficulty.EASY: "Easy",
	Difficulty.MEDIUM: "Medium",
	Difficulty.HARD: "Hard",
	Difficulty.LOGIC: "Logic?!",
	Difficulty.TASUKETE: "Tasukete",
}

var legacy:bool = true
var difficulty:int = Difficulty.UNKNOWN # LEGACY SUPPORT

var name:String
var unsupported:bool = false

var notes:Array
var data:Dictionary

class Note:
	var index:int
	var x:float
	var y:float
	var time:float
