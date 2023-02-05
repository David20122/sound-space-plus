extends ResourcePlus
class_name Song

enum Difficulty {
	UNKNOWN
	EASY
	MEDIUM
	HARD
	LOGIC
	TASUKETE
}
const DifficultyColours = {
	Difficulty.UNKNOWN: Color("#ffffff"),
	Difficulty.EASY: Color("#00ff00"),
	Difficulty.MEDIUM: Color("#ffb800"),
	Difficulty.HARD: Color("#ff0000"),
	Difficulty.LOGIC: Color("#d76aff"),
	Difficulty.TASUKETE: Color("#36304f"),
}

var name:String
var song:String
var difficulty:int = Difficulty.UNKNOWN
var cover:ImageTexture
var audio:AudioStream
var notes:Array

class Note:
	extends Reference
	var index:int
	var x:float
	var y:float
	var time:float