extends GameObject
class_name HitObject

signal on_hit_state_changed

enum HitState {
	NONE,
	HIT,
	MISS
}

var hittable:bool = true
var can_hit:bool = false
var hit_state:int = HitState.NONE:
	get: return hit_state
	set(value):
		hit_state = value
		on_hit_state_changed.emit(value)

func hit():
	if hit_state != HitState.NONE: return
	if !can_hit: return
	self.hit_state = HitState.HIT
func miss():
	if hit_state != HitState.NONE: return
	self.hit_state = HitState.MISS