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
const LegacyCovers = { # LEGACY SUPPORT
	Difficulty.UNKNOWN: null,
	Difficulty.EASY: preload("res://assets/images/covers/easy.png"),
	Difficulty.MEDIUM: preload("res://assets/images/covers/medium.png"),
	Difficulty.HARD: preload("res://assets/images/covers/hard.png"),
	Difficulty.LOGIC: preload("res://assets/images/covers/logic.jpg"),
	Difficulty.TASUKETE: preload("res://assets/images/covers/tasukete.png"),
}

var unsupported:bool = false

var notes:Array
var data:Dictionary

class Note:
	var index:int
	var x:float
	var y:float
	var time:float
