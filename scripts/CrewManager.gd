extends Node

signal crew_hp(max_value, min_value, value)
signal crew_status(helmsmanship, sail_handling, gunnery, reload, damage_control, recon)
signal complete_crew_status(crew)

const SHIP_PARTS := ["Hull", "Mast", "Rudder", "Crow's Nest", "Gunport", "Bow Chaser"]


var crew := [
	{"ID": "Boat", "name": "Going Merry – Boat", "desc": "The boat.", "Hull": 100, "Mast": 100, "Rudder": 100, "Crow's Nest": 100, "Gunport": 100, "Bow Chaser": 100},
	{"ID": "Crew", "name": "Nami – Navigator", "desc": "Trusts the charts and the Government. For now.", "Helmsmanship": 10, "Sail Handling": 10, "Gunnery": 10, "Reload": 10, "Damage Control": 10, "Recon": 10},
	{"ID": "Crew", "name": "Rook – Boatswain", "desc": "Old sailor, grumbles about 'things not adding up'.", "Helmsmanship": 10, "Sail Handling": 10, "Gunnery": 10, "Reload": 10, "Damage Control": 10, "Recon": 10},
	{"ID": "Crew", "name": "Isha – Comms", "desc": "Handles the Den Den Mushi and listens more than she speaks.", "Helmsmanship": 10, "Sail Handling": 10, "Gunnery": 10, "Reload": 10, "Damage Control": 10, "Recon": 10}
]


var max_hp := 100.0
var min_hp := 0.0
var current_hp := 100

var helmsmanship = 10
var sail_handling = 10
var gunnery = 5
var reload = 10
var damage_control = 10
var recon = 10


func request_complete_crew_status():
	complete_crew_status.emit(crew)


func request_crew_status():
	crew_status.emit(helmsmanship, sail_handling, gunnery, reload, damage_control, recon)


func request_crew_hp():
	crew_hp.emit(max_hp, min_hp, current_hp)



func apply_damage(damage, part):
	_set_hp(crew[0][part] - damage, part)


func _set_hp(new_hp: float, part: String) -> void:
	if not _is_valid_boat_part(part):
		push_error("Invalid boat part: %s" % part)
		return

	var clamped := clampf(new_hp, 0.0, 100.0)

	if is_equal_approx(clamped, float(crew[0][part])):
		return

	crew[0][part] = clamped

	current_hp = _compute_boat_integrity()

	complete_crew_status.emit(crew)
	crew_hp.emit(100.0, 0.0, current_hp)


func _compute_boat_integrity() -> float:
	var sum := 0.0
	for p in SHIP_PARTS:
		sum += float(crew[0][p])
	return sum / float(SHIP_PARTS.size())


func _is_valid_boat_part(part: String) -> bool:
	return SHIP_PARTS.has(part)
