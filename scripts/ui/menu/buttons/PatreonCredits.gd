extends Control

func _ready():
	var file:File = File.new()
	
	var p3:Array = []
	var p2:Array = []
	var p1:Array = []
	
	
	if file.open("res://patreon3.txt",File.READ) == OK: # will be FILE_NOT_FOUND if it doesn't exist
		p3 = file.get_as_text().split("\n",false)
		file.close()
	
	if file.open("res://patreon2.txt",File.READ) == OK:
		p2 = file.get_as_text().split("\n",false)
		file.close()
	
	if file.open("res://patreon1.txt",File.READ) == OK:
		p1 = file.get_as_text().split("\n",false)
		file.close()
	
	if p3.size() + p2.size() + p1.size() != 0:
		for n in p3:
			var label:Label = $S/L/T3/Label.duplicate()
			$S/L/T3.call_deferred("add_child",label)
			label.text = n
			label.visible = true
			
		for n in p2:
			var label:Label = $S/L/T2/Label.duplicate()
			$S/L/T2.call_deferred("add_child",label)
			label.text = n
			label.visible = true
			
		for n in p1:
			var label:Label = $S/L/T1/Label.duplicate()
			$S/L/T1.call_deferred("add_child",label)
			label.text = n
			label.visible = true
	
	elif has_node("../../CreditsBtn"): get_node("../../CreditsBtn").visible = false
