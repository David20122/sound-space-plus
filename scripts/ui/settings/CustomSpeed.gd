extends SpinBox

func upd():
	print("changing the thigny")
	Rhythia.custom_speed = value / 100

func _process(_d):
	if !is_equal_approx(value, Rhythia.custom_speed * 100): upd()
	#if value != Rhythia.custom_speed * 100: upd()

func _ready():
	value = Rhythia.custom_speed * 100
	connect("changed",self,"upd")
