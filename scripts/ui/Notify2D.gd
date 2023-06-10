extends VBoxContainer
class_name Notify2D

const colors:Dictionary = {
	0: { line = Color("#254e7f"), title = Color("#89cbff") }, # Info
	1: { line = Color("#805a00"), title = Color("#ffbe6b") }, # Warn
	2: { line = Color("#800000"), title = Color("#ffa4a4") }, # Error
	3: { line = Color("#257f33"), title = Color("#b1ff89") } # Succeed
}

onready var base = $Notify

func notify(type:int,body:String,title:String="Notification",time:float=5):
	var notif = base.duplicate()
	notif.get_node("H/Line").color = colors[type].line
	notif.get_node("H/Body/V/Title/L").modulate = colors[type].title
	notif.get_node("H/Body/V/Title/L").text = title
	notif.get_node("H/Body/V/Body/L").text = body
	add_child(notif)
	
	var twn:Tween = Tween.new()
	notif.add_child(twn)
	notif.modulate = Color(1,1,1,0)
	notif.visible = true
	twn.interpolate_property(notif,"modulate",Color(1,1,1,0),Color(1,1,1,1),0.25)
	twn.start()
	
	yield(get_tree().create_timer(time - 2),"timeout")
	
	twn.stop_all()
	twn.interpolate_property(notif,"modulate",Color(1,1,1,1),Color(1,1,1,0),2)
	twn.start()
	
	yield(get_tree().create_timer(2),"timeout")
	
	notif.queue_free()
