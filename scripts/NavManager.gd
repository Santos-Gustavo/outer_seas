extends Node
#class_name NavManager

signal position_changed(true_pos: Vector2, estimated_pos: Vector2, error_radius: float)
signal heading_changed(new_heading_deg: float)
signal nav_message(text: String)

var ship_pos: Vector2 = Vector2.ZERO
var est_ship_pos: Vector2 = Vector2.ZERO
var est_error_radius: float = 50.0

var ship_heading_deg: float = 90.0  # 0 = east, 90 = north (you can change convention)
var navigator_skill: float = 0.5    # 0..1

# Continuous movement parameters
var is_anchored: bool = false
var boat_speed_km_per_day: float = 100.0
var seconds_per_game_day: float = 3.0    # at time_scale = 1.0
var time_scale: float = 1.0              # 1x..5x
var game_time_days: float = 0.0

var distance_travelled_current_day_km: float = 0.0
var distance_travelled_last_day_km: float = 0.0


signal day_finished(day_index: int, distance_km: float)

const KM_TO_UNITS: float = 1.0

# World bounds (adjust to your map)
const NAV_BOUNDS := Rect2(
	Vector2(0.0, 0.0),
	Vector2(2750.0, 1550.0)
)


func _ready() -> void:
	randomize()
	set_process(true)
	_emit_position_changed()
	nav_message.emit("Navigation systems online.")


func _process(delta: float) -> void:
	# If anchored, no movement
	if is_anchored:
		return

	var game_days_elapsed := _compute_game_days_elapsed(delta)
	if game_days_elapsed <= 0.0:
		return

	game_time_days += game_days_elapsed
	_integrate_movement(game_days_elapsed)


# -------------------------------------------------------------------
# Public API
# -------------------------------------------------------------------

func set_heading(degrees: float) -> void:
	ship_heading_deg = _normalize_degrees(degrees)
	heading_changed.emit(ship_heading_deg)
	nav_message.emit("Heading set to %.1f°" % ship_heading_deg)


func set_anchored(value: bool) -> void:
	if is_anchored == value:
		return
	is_anchored = value
	if is_anchored:
		nav_message.emit("Anchor dropped. Ship holds position.")
	else:
		nav_message.emit("Anchor lifted. Ship underway.")


func set_time_scale(scale: float) -> void:
	time_scale = clamp(scale, 0.0, 5.0)
	nav_message.emit("Time scale set to %.1fx" % time_scale)


func set_boat_speed_km_per_day(speed: float) -> void:
	boat_speed_km_per_day = max(speed, 0.0)
	nav_message.emit("Cruising speed set to %.0f km/day" % boat_speed_km_per_day)


func get_estimated_position() -> Vector2:
	return est_ship_pos


func get_true_position() -> Vector2:
	return ship_pos


func get_error_radius() -> float:
	return est_error_radius


func get_heading() -> float:
	return ship_heading_deg


# -------------------------------------------------------------------
# Internal: time & movement integration
# -------------------------------------------------------------------
func _should_move(days: float) -> bool:
	if days <= 0.0:
		return false
	if boat_speed_km_per_day <= 0.0:
		return false
	return true


func _compute_travel_distance(days: float) -> float:
	return boat_speed_km_per_day * days


func _compute_game_days_elapsed(delta: float) -> float:
	if seconds_per_game_day <= 0.0:
		return 0.0
	return delta * time_scale / seconds_per_game_day


func _split_distance_across_day_boundary(
	old_day_index: int,
	old_game_time_days: float,
	days: float,
	actual_distance: float
) -> void:
	var day_boundary_time: float = float(old_day_index) + 1.0
	var time_before_boundary: float = day_boundary_time - old_game_time_days
	var fraction_before: float = 0.0

	if days > 0.0:
		fraction_before = clamp(time_before_boundary / days, 0.0, 1.0)

	var distance_before: float = actual_distance * fraction_before
	var distance_after: float = actual_distance - distance_before

	# Finalize previous day
	distance_travelled_last_day_km = distance_travelled_current_day_km + distance_before
	day_finished.emit(old_day_index, distance_travelled_last_day_km)

	# Start new day with leftover distance
	distance_travelled_current_day_km = distance_after


func _update_day_tracking(days: float, actual_distance: float) -> void:
	var old_day_index: int = int(floor(game_time_days))
	var old_game_time_days: float = game_time_days

	# Advance game time
	game_time_days += days
	var new_day_index: int = int(floor(game_time_days))

	if new_day_index == old_day_index:
		# Stayed within the same in-game day
		distance_travelled_current_day_km += actual_distance
	else:
		# Crossed a day boundary (with your timestep this will be at most one)
		_split_distance_across_day_boundary(
			old_day_index,
			old_game_time_days,
			days,
			actual_distance
		)


func _integrate_movement(days: float) -> void:
	if not _should_move(days):
		return

	var distance_km: float = _compute_travel_distance(days)
	if distance_km <= 0.0:
		return

	var actual_distance: float = _move_true_position(distance_km)
	_update_estimate_after_travel(actual_distance)
	_emit_position_changed()

	_update_day_tracking(days, actual_distance)


func get_distance_travelled_current_day() -> float:
	return distance_travelled_current_day_km


func get_distance_travelled_last_day() -> float:
	return distance_travelled_last_day_km


func _move_true_position(distance_km: float) -> float:
	var rad: float = deg_to_rad(ship_heading_deg)
	var direction: Vector2 = Vector2(cos(rad), sin(rad))

	var desired_delta: Vector2 = direction * distance_km * KM_TO_UNITS
	var desired_pos: Vector2 = ship_pos + desired_delta

	var clamped_pos: Vector2 = _clamp_to_bounds(desired_pos)
	var actual_delta: Vector2 = clamped_pos - ship_pos
	var actual_distance: float = actual_delta.length() / KM_TO_UNITS

	#if actual_distance < distance_km:
		#nav_message.emit("The sea seems to end here. You can't sail further in that direction.")

	ship_pos = clamped_pos
	return actual_distance


func _update_estimate_after_travel(distance_km: float) -> void:
	var rad: float = deg_to_rad(ship_heading_deg)
	var direction: Vector2 = Vector2(cos(rad), sin(rad))
	var ideal_delta: Vector2 = direction * distance_km * KM_TO_UNITS

	var drift: Vector2 = _compute_drift(distance_km)

	est_ship_pos += ideal_delta #+ drift
	est_ship_pos = _clamp_to_bounds(est_ship_pos)

	_update_error_radius(distance_km, drift.length())


func _compute_drift(distance_km: float) -> Vector2:
	var base_error: float = distance_km * 0.15
	var clamped_skill: float = clamp(navigator_skill, 0.0, 1.0)
	var skill_factor: float = 1.0 - clamped_skill
	var env_factor: float = _current_env_error_multiplier()

	var error_magnitude: float = base_error * skill_factor * env_factor
	var error_angle: float = randf_range(-PI, PI)
	return Vector2(cos(error_angle), sin(error_angle)) * error_magnitude


func _current_env_error_multiplier() -> float:
	# Later: storms / currents can change this
	return 1.0


func _update_error_radius(distance_km: float, drift_magnitude: float) -> void:
	var inflate: float = distance_km * 0.05
	est_error_radius = max(est_error_radius + inflate, drift_magnitude)



func _emit_position_changed() -> void:
	position_changed.emit(ship_pos, est_ship_pos, est_error_radius)


func _clamp_to_bounds(pos: Vector2) -> Vector2:
	var x = clamp(pos.x, NAV_BOUNDS.position.x, NAV_BOUNDS.position.x + NAV_BOUNDS.size.x)
	var y = clamp(pos.y, NAV_BOUNDS.position.y, NAV_BOUNDS.position.y + NAV_BOUNDS.size.y)
	return Vector2(x, y)


func _normalize_degrees(deg: float) -> float:
	var result: float = fmod(deg, 360.0)
	if result < 0.0:
		result += 360.0
	return result
