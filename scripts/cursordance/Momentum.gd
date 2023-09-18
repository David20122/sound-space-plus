extends DanceMover
class_name MomentumDanceMover # Momentum

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
	return (time - StartTime) / max(Duration,0.01)


func AngleRV(v1:Vector2,v2:Vector2) -> float:
	return atan2(v1.y - v2.y, v1.x - v2.x);
func V2FromRad(rad:float, radius:float) -> Vector2:
	return Vector2(cos(rad) * radius, sin(rad) * radius);


func AngleBetween(centre:Vector2, v1:Vector2, v2:Vector2)->float:
	var a = centre.distance_to(v1)
	var b = centre.distance_to(v2)
	var c = v1.distance_to(v2)
	
	return acos((a * a + b * b - c * c) / (2 * a * b));



var notes:PoolVector3Array = PoolVector3Array()

func _init(song:Song):
	for n in song.read_notes():
		notes.append(Vector3(n[0],n[1],n[2]))

func v2(v:Vector3) -> Vector2:
	return Vector2(v.x,v.y)

var noteNum = 1

func nextAngle() -> float:
	for i in range(noteNum, notes.size() - 2):
		var o = notes[i];
		if (!same3(o, notes[i + 1])):
			return v2(o).angle_to_point(v2(notes[i + 1]));
	
	return (StartPos.angle_to_point(last) + PI);

func onObjChange():
	var dst = (StartPos - EndPos).length()
	
	var a2 = nextAngle()
	var afs = nextAngle()
	var a1 = a2 + PI
	
	if noteNum != 0:
		a1 = StartPos.angle_to_point(last)

	p1 = V2FromRad(a1, dst * jmult) + StartPos;

	var a = EndPos.angle_to_point(StartPos);
	if (!afs && abs(a2 - a) < offset):
		if (a2 - a < offset): a2 = a - offset
		else: a2 = a + offset
	p2 = V2FromRad(a2, dst * nmult) + EndPos;

	if (!same(StartPos, EndPos)):
		last = p2;

var t
var r
var tme

func _update(time:float) -> Vector2:
	var lastNoteNum = noteNum
	for i in range(noteNum, notes.size() - 2):
		var o = notes[i+1];
		if (o.z > time):
			noteNum = i
			Start = notes[i]
			End = notes[i+1]
			StartPos = v2(Start)
			EndPos = v2(End)
			StartTime = Start.z
			EndTime = End.z
			Duration = EndTime - StartTime
			break
	
	tme = time
	offset = PI * offsetMult
	onObjChange()
	
	
	t = clamp(T(time),0,1);
	
	r = 1 - t;
	
	return Vector2(
		r * r * r * StartX
		+ r * r * t * p1.x * 3
		+ r * t * t * p2.x * 3
		+ t * t * t * EndX,
		r * r * r * StartY
		+ r * r * t * p1.y * 3
		+ r * t * t * p2.y * 3
		+ t * t * t * EndY
	)
