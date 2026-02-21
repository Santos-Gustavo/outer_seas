extends Node


signal crew_hp_changed(max_value: float, min_value: float, value: float)
signal crew_stats_changed(stats: Dictionary)
signal crews_loaded(all_crews: Dictionary)
signal active_crew_changed(active_crew: Dictionary)

const DATA_PATH := "res://data/crews.json"
const SHIP_PARTS := ["Hull", "Mast", "Rudder", "Crow's Nest", "Gunport", "Bow Chaser"]

var all_crews: Dictionary = {}
var active_crew_id: String = "main"
var active_crew: Dictionary = {}

func _ready() -> void:
	_load_crews()
	if all_crews.has(active_crew_id):
		set_active_crew(active_crew_id)

# -------------------------
# Loading
# -------------------------

func _load_crews() -> void:
	if not FileAccess.file_exists(DATA_PATH):
		push_error("CrewManager: crews.json not found at %s" % DATA_PATH)
		return

	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	var parsed_any = JSON.parse_string(file.get_as_text())
	file.close()

	if typeof(parsed_any) != TYPE_DICTIONARY:
		push_error("CrewManager: failed to parse crews.json")
		return

	var parsed: Dictionary = parsed_any

	if not parsed.has("crews") or typeof(parsed["crews"]) != TYPE_DICTIONARY:
		push_error("CrewManager: 'crews' key missing or invalid")
		return

	all_crews = parsed["crews"]
	crews_loaded.emit(all_crews)

# -------------------------
# Active crew selection
# -------------------------

func set_active_crew(crew_id: String) -> void:
	if not all_crews.has(crew_id):
		push_error("CrewManager: unknown crew_id %s" % crew_id)
		return

	active_crew_id = crew_id
	active_crew = all_crews[crew_id]
	active_crew_changed.emit(active_crew)

	_emit_hp()
	_emit_stats(crew_id)

# -------------------------
# Queries
# -------------------------

func get_boat_parts() -> Dictionary:
	return active_crew.get("boat", {}).get("parts", {})

func get_members() -> Array:
	return active_crew.get("members", [])

# -------------------------
# HP / Integrity
# -------------------------

func apply_damage(damage: float, part: String) -> void:
	if not SHIP_PARTS.has(part):
		push_error("CrewManager: invalid ship part %s" % part)
		return

	var parts := get_boat_parts()
	if parts.is_empty():
		push_error("CrewManager: no boat parts loaded")
		return

	var current := float(parts.get(part, 0.0))
	var clamped := clampf(current - damage, 0.0, 100.0)

	if is_equal_approx(clamped, current):
		return

	parts[part] = clamped
	_emit_hp()
	active_crew_changed.emit(active_crew) # so UI can refresh parts display

func get_boat_integrity() -> float:
	var parts := get_boat_parts()
	var sum := 0.0
	for p in SHIP_PARTS:
		sum += float(parts.get(p, 0.0))
	return sum / float(SHIP_PARTS.size())

func _emit_hp() -> void:
	crew_hp_changed.emit(100.0, 0.0, get_boat_integrity())

# -------------------------
# Crew stats (derived)
# -------------------------

func get_crew_stats_by_id(crew_id: String) -> Dictionary:
	if not all_crews.has(crew_id):
		push_error("CrewManager: unknown crew_id %s" % crew_id)
		return {}

	var entry: Dictionary = all_crews[crew_id]
	var members: Array = entry.get("members", [])

	return _compute_stats_from_members(members)

func _compute_stats_from_members(members: Array) -> Dictionary:
	var totals := {
		"Helmsmanship": 0.0,
		"Sail Handling": 0.0,
		"Gunnery": 0.0,
		"Reload": 0.0,
		"Damage Control": 0.0,
		"Recon": 0.0
	}

	if members.is_empty():
		return totals

	for m in members:
		var s: Dictionary = m.get("stats", {})
		for k in totals.keys():
			totals[k] += float(s.get(k, 0.0))

	var count := float(members.size())
	for k in totals.keys():
		totals[k] /= count

	return totals

func _emit_stats(crew_id) -> void:
	crew_stats_changed.emit(get_crew_stats_by_id(crew_id))
