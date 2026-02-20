extends Node

signal crew_hp(max_value, min_value, value)
signal crew_status(helmsmanship, sail_handling, gunnery, reload, damage_control, recon)

var max_hp := 100.0
var min_hp := 0.0
var current_hp := 100.0

var helmsmanship = 10
var sail_handling = 10
var gunnery = 5
var reload = 10
var damage_control = 10
var recon = 10


func request_crew_status():
	crew_status.emit(helmsmanship, sail_handling, gunnery, reload, damage_control, recon)


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
