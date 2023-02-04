extends Resource
class_name Song

enum Difficulty {
	UNKNOWN
	EASY
	MEDIUM
	HARD
	LOGIC
	TASUKETE
}

var broken:bool = false

var id:String
var name:String
var song:String
var creator:String
var difficulty:int = Difficulty.UNKNOWN
var cover:ImageTexture
var notes:Array

class Note:
	extends Reference
	var x:float
	var y:float
	var time:float