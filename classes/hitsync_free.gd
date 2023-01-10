extends AudioStreamPlayer

func _ready():
	yield(get_tree().create_timer(stream.get_length()),"timeout")
