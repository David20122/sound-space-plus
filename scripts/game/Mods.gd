extends Resource
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

var data:Dictionary:
	get:
		return {
			speed_mod = speed_mod,
			speed_preset = speed_preset,
			speed_custom = speed_custom,
			no_fail = no_fail
		}
	set(value):
		speed_mod = value.get("speed_mod",speed_mod)
		speed_preset = value.get("speed_preset",speed_preset)
		speed_custom = value.get("speed_custom",speed_custom)
		no_fail = value.get("no_fail",no_fail)
