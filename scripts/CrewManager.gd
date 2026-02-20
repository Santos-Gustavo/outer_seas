extends Node

signal crew_hp(max_value, min_value, value)

var max_hp := 50.0
var min_hp := 0.0
var current_hp := 50.0

func request_crew_hp():
	crew_hp.emit(max_hp, min_hp, current_hp)


func apply_damage(damage):
	_set_hp(current_hp - damage)


func _set_hp(new_hp: float) -> void:
	var clamped := clampf(new_hp, 0.0, 50.0)
	if is_equal_approx(clamped, current_hp):
		return

	current_hp = clamped
	crew_hp.emit(max_hp, min_hp, current_hp)
