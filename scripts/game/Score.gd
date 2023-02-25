extends Object
class_name Score

var score:int = 0

var multiplier:int = 1:
	get: return multiplier
	set(value):
		multiplier = clampi(value,1,8)
var sub_multiplier:int = 0:
	get: return sub_multiplier
	set(value):
		sub_multiplier = clampi(value,0,8)

var hits:int = 0
var misses:int = 0
var total:int:
	get:
		return hits + misses
const RankLetters = [
	[1,"SS"],
	[0.98,"S"],
	[0.95,"A"],
	[0.9,"B"],
	[0.85,"C"],
	[0.8,"D"],
	[0.75,"E"],
	[0,"F"]
]
var rank:String:
	get:
		if total > 0:
			for letter in RankLetters:
				if hits >= total * letter[0]:
					return letter[1]
		return "SS"


var combo:int = 0:
	get: return combo
	set(value):
		combo = value
		if combo > max_combo:
			max_combo = combo
var max_combo:int = 0

var submitted:bool = false
