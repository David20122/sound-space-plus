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
var hit_state:int = HitState.NONE

func hit():
	if hit_state != HitState.NONE: return
	if !can_hit: return
	hit_state = HitState.HIT
	on_hit_state_changed.emit(hit_state)
func miss():
	if hit_state != HitState.NONE: return
	hit_state = HitState.MISS
	on_hit_state_changed.emit(hit_state)
