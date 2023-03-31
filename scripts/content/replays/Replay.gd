extends ResourcePlus
class_name Replay

const SIGNATURE:PackedByteArray = [0x53,0x73,0x2A,0x52]

var frames:Array[Frame]

class Frame:
	enum Type {
		CURSOR,
		HIT
	}
	var index:int
	var type:int
	var position:Vector2
	var note_index:int