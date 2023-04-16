extends ColorRect

func _ready():
	$HitWindow.text = "%.0f ms" % SSP.hitwindow_ms
	$Approach.text = "%.1f" % SSP.get("approach_rate")
	if SSP.get("cam_unlock"): $Camera.text = "SPIN"
	$Parallax.text = "%.02f" % SSP.get("parallax")
	$Sensitivity.text = "%.02f" % SSP.sensitivity
	$Hitbox.text = "%.02f (%+.02f)" % [SSP.note_hitbox_size,SSP.note_hitbox_size-1.27]
	if SSP.get("edge_drift") != 0: $EdgeBuffer.text = "%.02f" % SSP.get("edge_drift")
