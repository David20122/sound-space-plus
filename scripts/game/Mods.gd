extends Object
class_name Mods

enum Speed {
	PRESET,
	CUSTOM
}
const SpeedPresets = [
	1.0/1.35,
	1.0/1.25,
	1.0/1.15,
	1,
	1.15,
	1.25,
	1.35
]
var speed_mod = Speed.PRESET
var speed_preset = 3
var speed_custom = 1
var speed:float:
	get:
		if speed_mod == Speed.PRESET:
			return SpeedPresets[speed_preset]
		else:
			return speed_custom

var no_fail:bool = false
