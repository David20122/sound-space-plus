extends Object
class_name PathAnimation

enum EasingType {
	Linear,
	Sine
}
enum EasingDirection {
	In,
	Out,
	InOut,
	OutIn
}

var points:Array[Point]

class Point:
	var data:Array
	var time:float
	var easeType:int
	var easeDirection:int
	var splineType:int
