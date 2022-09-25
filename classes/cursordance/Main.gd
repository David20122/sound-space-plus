extends ColorRect

var notes:PoolVector3Array = PoolVector3Array()
var noten:int = 0

var colors = SSP.selected_colorset.colors

var active:bool = false



func mc(col:Color,m:float) -> Color:
	return Color(col.r*m,col.g*m,col.b*m,col.a) 

func ma(col:Color,m:float) -> Color:
	return Color(col.r,col.g,col.b,col.a*m)

func _draw():
	var nt:float = 1000
	if active:
		var ms = get_parent().ms
		if noten <= notes.size():
			for i in range( noten, min(noten+15,notes.size())  ):
				var n:Vector3 = notes[i]
				var off = n.z - ms
				if off <= 0:
					$Hit.play()
					noten = i + 1
				elif off > nt: pass
				else:
					var m = (1.0 - (off/nt))
					var poff = ((120 * ((off/nt))) + 45) - (4*Dance.InQuint(m))
					draw_rect(
						Rect2(
							50+(n.x*100)-poff,
							50+(n.y*100)-poff,
							poff*2,
							poff*2
						),
						ma(colors[fmod(i,colors.size())],Dance.InQuint(m)),
						false, 2, true #*(1.0-(off/nt))
					)
					draw_rect(
						Rect2(10 + (n.x*100), 10 +(n.y*100), 80, 80),
						ma(Color(0.5,0.5,0.5),0.5*Dance.InQuint(m)),
						false, 3, false
					)

func _process(delta):
	update()

func setup(song:Song):
	$Hit.stream = SSP.hit_snd
	for n in song.read_notes():
		notes.append(Vector3(n[0],n[1],n[2]))
