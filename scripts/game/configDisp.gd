extends ColorRect

func _ready():
	$HitWindow.text = "%.0f ms" % Rhythia.hitwindow_ms
	$Approach.text = "%.1f" % Rhythia.get("approach_rate")
	if Rhythia.get("cam_unlock"): $Camera.text = "SPIN"
	$Parallax.text = "%.02f" % Rhythia.get("parallax")
	$Sensitivity.text = "%.02f" % Rhythia.sensitivity
	$Hitbox.text = "%.02f (%+.02f)" % [Rhythia.note_hitbox_size,Rhythia.note_hitbox_size-1.27]
	if Rhythia.get("edge_drift") != 0: $EdgeBuffer.text = "%.02f" % Rhythia.get("edge_drift")
