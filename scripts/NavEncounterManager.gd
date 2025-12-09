extends Node
#class_name NavEncounterManager

signal region_entered(id: String)
signal region_exited(id: String)

# List of regions (islands, hazards, etc.)
var regions: Array = []

# Internal: which regions we're currently inside (id -> true)
var _active_region_ids: Dictionary = {}


func _ready() -> void:
	_init_regions()
	# Listen to navigation updates from NavManager
	NavManager.position_changed.connect(_on_nav_position_changed)


# -------------------------------------------------------------------
# Region definitions
# -------------------------------------------------------------------

func _init_regions() -> void:
	# World coordinates must match NavManager's coordinate system
	regions = [
		{
			"id": "capital",
			"type": "island",
			"shape": "circle",
			"center": Vector2(500, 1000),
			"radius": 50.0,
			"event_on_enter": "cap_dock_arrival"
		},
		{
			"id": "ashfall",
			"type": "island",
			"shape": "circle",
			"center": Vector2(320, -120),
			"radius": 60.0,
			"event_on_enter": "ash_dock_tension"
		},
		{
			"id": "storm_edge",
			"type": "hazard",
			"shape": "circle",
			"center": Vector2(600, 50),
			"radius": 120.0,
			"event_on_enter": "storm_edge_scan"
		}
	]


# -------------------------------------------------------------------
# Signal handlers
# -------------------------------------------------------------------

func _on_nav_position_changed(true_pos: Vector2, est_pos: Vector2, error_radius: float) -> void:
	_update_regions_for_position(true_pos)


# -------------------------------------------------------------------
# Region enter/exit detection
# -------------------------------------------------------------------

func _update_regions_for_position(pos: Vector2) -> void:
	var new_region_ids: Dictionary = {}  # id -> true

	# Find all regions that contain this position
	for region in regions:
		if _position_inside_region(pos, region):
			new_region_ids[region["id"]] = true

	# Entered regions: in new, not in active
	for id in new_region_ids.keys():
		if not _active_region_ids.has(id):
			_active_region_ids[id] = true
			region_entered.emit(id)
			_handle_region_entered(id)

	# Exited regions: in active, not in new
	for id in _active_region_ids.keys():
		if not new_region_ids.has(id):
			_active_region_ids.erase(id)
			region_exited.emit(id)


func _position_inside_region(pos: Vector2, region: Dictionary) -> bool:
	var shape: String = region.get("shape", "circle")

	match shape:
		"circle":
			var center: Vector2 = region.get("center", Vector2.ZERO)
			var radius: float = region.get("radius", 0.0)
			return pos.distance_to(center) <= radius

		"rect":
			var rect: Rect2 = region.get("rect", Rect2())
			return rect.has_point(pos)

		_:
			return false


# -------------------------------------------------------------------
# Event hookup
# -------------------------------------------------------------------

func _handle_region_entered(id: String) -> void:
	var region: Dictionary = _get_region_by_id(id)
	if region.is_empty():
		return

	var event_id: String = region.get("event_on_enter", "")
	if event_id == "":
		return

	# Let EventManager decide how to run it (once, flags, etc.)
	print(region)
	print(event_id)
	if EventManager.has_event(event_id):
		EventManager.start_event(event_id)


func _get_region_by_id(id: String) -> Dictionary:
	for region in regions:
		if region.get("id", "") == id:
			return region
	return {}
