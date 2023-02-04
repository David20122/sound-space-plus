extends Node

func _ready():
	SoundSpacePlus.connect("on_init_stage",self,"_on_init_stage")

func _on_init_stage(stage,progress=[]):
	if stage != null: $Container/Label.text = stage
	$Container/ProgressBar1.visible = false
	$Container/ProgressBar2.visible = false
	$Container/ProgressBar3.visible = false
	var i = 1
	for bar in progress:
		var node = get_node("Container/ProgressBar%s" % i)
		node.get_node("Label").text = bar.text
		var progress_bar = node.get_node("Bar")
		progress_bar.max_value = bar.max
		progress_bar.value = bar.value
		node.visible = true
		i += 1