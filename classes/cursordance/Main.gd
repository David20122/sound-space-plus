extends Panel

var notes:PoolVector3Array = PoolVector3Array()
var noten:int = 0

var colors = SSP.selected_colorset.colors

var active:bool = true

func mc(col:Color,m:float) -> Color:
	return Color(col.r*m,col.g*m,col.b*m,col.a) 

func ma(col:Color,m:float) -> Color:
	return Color(col.r,col.g,col.b,col.a*m)

var flash_time:float = 0

func tp(v:Vector2) -> Vector2:
	return v*100+Vector2(50,50)

func _draw():
	var nt:float = 1000.0 * Globals.speed_multi[SSP.mod_speed_level]
	var gray:Color = Color(0.075,0.075,0.075)
	draw_line(Vector2(100,0),Vector2(100,300),gray,1)
	draw_line(Vector2(200,0),Vector2(200,300),gray,1)
	draw_line(Vector2(0,100),Vector2(300,100),gray,1)
	draw_line(Vector2(0,200),Vector2(300,200),gray,1)
	draw_rect(Rect2(0,0,300,300),Color(0.15 + (flash_time * 0.4),0.15,0.15),false,2,false)
	
#	var dance = get_parent().dance
#	var col1:Color = Color(0.8,0.1,0.1)
#	var col2:Color = Color(0.2,0.8,0.2)
#	var col3:Color = Color(0.3,0.3,0.8)
#	var col4:Color = Color(0.8,0.1,0.8)
#	var bgray:Color = Color(0.15,0.15,0.15)
#	var v50:Vector2 = Vector2(50,50)
	
	
#
#	draw_circle(tp(dance.pts[1]),4,gray)
#	draw_circle(tp(dance.pts[2]),4,gray)

#	draw_line(tp(dance.pts[0]),tp(dance.pts[1]),ma(col1,0.5),1,true)
#	draw_line(tp(dance.pts[2]),tp(dance.pts[3]),ma(col3,0.5),1,true)
#	draw_circle(tp(dance.pts[4]),6,col1)
#	draw_circle(tp(dance.pts[0]),10,col2)
#	draw_circle(tp(dance.pts[3]),10,col3)
#	draw_circle(tp(dance.pts[5]),6,col4)

#	for ri in range(20):
#		var i = floor(float(ri)/2)
#		var t = float(ri)/19.0
#		var a = clamp(1.0 - (2*abs(t-dance.t)),0,1)
#		draw_line(tp(dance.bez[i]),tp(dance.bez[i+1]),ma(bgray,a),2,true)
	
#	draw_line(tp(dance.pts[4]),tp(dance.pts[0]),gray,2,true)
#	draw_line(tp(dance.pts[0]),tp(dance.pts[3]),gray,2,true)
#	draw_line(tp(dance.pts[3]),tp(dance.pts[5]),gray,2,true)
	
	flash_time = max(flash_time - get_process_delta_time(),0)
	if active:
		var ms = get_parent().ms
		if noten != 0 and ms < notes[noten-1].z:
			if noten > (notes.size() - 1): noten = (notes.size()-1)
			for i in range(min(noten,notes.size()), -1):
				if notes[i].z - ms <= 0:
					noten = i + 1
					break
			if ms < notes[noten].z: # if it hasn't changed
				noten = 0
		
		if noten <= notes.size():
			for i in range( noten, notes.size() ):
				var n:Vector3 = notes[i]
				var off = n.z - ms
				if off <= 0:
					if get_parent().active: $Hit.play()
					noten = i + 1
				elif off > nt: break
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
						ma(Color(0.3,0.3,0.3),0.35 * Dance.InQuint(m)),
						false, 2, true #*(1.0-(off/nt))
					)
					draw_rect(
						Rect2(10 + (n.x*100), 10 +(n.y*100), 80, 80),
						ma(colors[fmod(i,colors.size())],0.5*Dance.InQuint(m)),
						false, 3, false
					)
					draw_rect(
						Rect2(11+(n.x*100), 12+(n.y*100), 77, 77),
						ma(colors[fmod(i,colors.size())],0.2*Dance.InQuint(m)),
						true
					)

func _process(delta):
	if active: update()

func setup(song:Song):
	$Hit.stream = SSP.hit_snd
	for n in song.read_notes():
		notes.append(Vector3(n[0],n[1],n[2]))
