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
const DifficultyNames = { # LEGACY SUPPORT
	Difficulty.UNKNOWN: "N/A",
	Difficulty.EASY: "Easy",
	Difficulty.MEDIUM: "Medium",
	Difficulty.HARD: "Hard",
	Difficulty.LOGIC: "Logic?!",
	Difficulty.TASUKETE: "Tasukete",
}

var name:String
var unsupported:bool = false

var notes:Array
var data:Dictionary

class Note:
	var index:int
	var x:float
	var y:float
	var time:float
