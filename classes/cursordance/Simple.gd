extends DanceMover
class_name SimpleDanceMover

var jmult:float = 1
var nmult:float = 1
var offsetMult:float = 1
var skipstacks:bool = true
var offset:float# = PI * offsetMult

var p1:Vector2
var p2:Vector2
var last:Vector2

func same(o1:Vector2, o2:Vector2): return o1 == o2
func same3(o1:Vector3, o2:Vector3): return (Vector2(o1.x,o1.y) == Vector2(o2.x,o2.y))

var Start:Vector3
var End:Vector3

var StartPos:Vector2
var StartTime:float
var EndPos:Vector2
var EndTime:float
var Duration:float

var StartX:float
var StartY:float
var EndX:float
var EndY:float

func T(time:float) -> float:
	return abs(time - StartTime) / max(Duration,0.01)

var notes:PoolVector3Array = PoolVector3Array()

func _init(song:Song):
	for n in song.read_notes():
		notes.append(Vector3(n[0],n[1],n[2]))

func v2(v:Vector3) -> Vector2:
	return Vector2(v.x,v.y)

var noteNum = 1

var t
var r
var tme

func _update(ms:float) -> Vector2:
	if noteNum != 0 and ms < notes[noteNum].z:
		for i in range(noteNum, -1):
			if notes[i].z - ms <= 0:
				noteNum = i
				break
		if ms < notes[noteNum].z: # if it hasn't changed
			noteNum = 0
	
	for i in range(noteNum, notes.size()):
		var o = notes[i];
		if (o.z > ms):
			noteNum = max(i-1,0)
			Start = notes[i-1]
			End = notes[i]
			StartPos = v2(Start)
			EndPos = v2(End)
			StartTime = Start.z
			EndTime = End.z
			Duration = EndTime - StartTime
			break
	
	var a2 = Vector2(Start.x,Start.y)
	var b2 = Vector2(End.x,End.y)
	
	t = clamp((ms - Start.z) / (End.z - Start.z),0,1)
	
	return lerp(StartPos,EndPos,Dance.InOutQuad(t))#Dance.Linear(t))
