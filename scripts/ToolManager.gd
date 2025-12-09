extends Node
#class_name ToolManager

signal tool_used(id: String, result: Dictionary)

# Public API ---------------------------------------------------------

func use_spyglass() -> void:
	var ship_pos: Vector2 = NavManager.get_true_position()
	var result: Dictionary = _spyglass_scan_around(ship_pos)
	tool_used.emit("spyglass", result)


# Internal -----------------------------------------------------------

func _spyglass_scan_around(ship_pos: Vector2) -> Dictionary:
	var scan_min_dist: float = 150.0   # km-equivalent in your world units
	var scan_max_dist: float = 400.0

	var best_region_id: String = ""
	var best_region_dir: Vector2 = Vector2.ZERO
	var best_region_dist: float = INF

	for region in NavEncounterManager.regions:
		if not region.get("hidden_event", false):
			continue

		var center: Vector2 = region.get("center", Vector2.ZERO)
		var dist: float = ship_pos.distance_to(center)
		if dist < scan_min_dist or dist > scan_max_dist:
			continue

		if dist < best_region_dist:
			best_region_dist = dist
			best_region_id = region.get("id", "")
			best_region_dir = (center - ship_pos).normalized()

	if best_region_id == "":
		return {
			"found": false
		}

	var angle_rad: float = atan2(best_region_dir.y, best_region_dir.x)
	var dir_label: String = _direction_label_from_angle(angle_rad)

	return {
		"found": true,
		"region_id": best_region_id,
		"distance": best_region_dist,
		"direction_label": dir_label
	}


func _direction_label_from_angle(angle_rad: float) -> String:
	var deg: float = rad_to_deg(angle_rad)
	if deg < 0.0:
		deg += 360.0

	if deg >= 45.0 and deg < 135.0:
		return "south"
	elif deg >= 135.0 and deg < 225.0:
		return "west"
	elif deg >= 225.0 and deg < 315.0:
		return "north"
	else:
		return "east"
		
