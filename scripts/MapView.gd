extends Control

@onready var nav_log: NavLogPanel = %NavLogPanel

@onready var ship_marker: Control = %ShipMarker
@onready var city_marker: Control = %CityMarker
@onready var log_pose_needle: TextureRect = %Needle

@onready var btn_heading_east: Button  = %TravelEast100Button
@onready var btn_heading_south: Button = %TravelSouth100Button
@onready var btn_heading_west: Button  = %TravelWest100Button
@onready var btn_heading_north: Button = %TravelNorth100Button

@onready var btn_anchor_toggle: Button = %AnchorToggleButton
@onready var btn_speed_0x: Button      = %Speed0xButton
@onready var btn_speed_1x: Button      = %Speed1xButton
@onready var btn_speed_3x: Button      = %Speed3xButton
@onready var btn_speed_5x: Button      = %Speed5xButton


# Simple conversion from world coords (km) to map coords (pixels)
const MAP_SCALE: float = 1.0
const MAP_OFFSET: Vector2 = Vector2(50.0, 0.0)
var log_pose_target_pos: Vector2 = Vector2(320, 120)  # same as your ashfall center
var log_pose_target_id: String = "ashfall"


func _ready() -> void:
	# Listen to navigation updates
	NavManager.position_changed.connect(_on_nav_position_changed)

	# Heading / speed / anchor controls
	_setup_heading_controls()
	_setup_speed_controls()
	_setup_anchor_button()

	# Initial markers
	_set_city_marker_position()
	var est_pos: Vector2 = NavManager.get_estimated_position()
	_update_ship_marker(est_pos)
	log_pose_needle.pivot_offset = log_pose_needle.size / 2.0
	log_pose_target_pos = WorldLocations.get_position(log_pose_target_id)

	# React to entering regions (visual feedback)
	NavEncounterManager.region_entered.connect(func(id: String) -> void:
		_highlight_marker_for_region(id)
	)


func _setup_heading_controls() -> void:
	# 0° = east, 90° = south, 180° = west, 270° = north
	btn_heading_east.pressed.connect(func() -> void:
		NavManager.set_heading(0.0)
	)
	btn_heading_south.pressed.connect(func() -> void:
		NavManager.set_heading(90.0)
	)
	btn_heading_west.pressed.connect(func() -> void:
		NavManager.set_heading(180.0)
	)
	btn_heading_north.pressed.connect(func() -> void:
		NavManager.set_heading(270.0)
	)


func _setup_speed_controls() -> void:
	btn_speed_0x.pressed.connect(func() -> void:
		NavManager.set_time_scale(0.0)
	)
	btn_speed_1x.pressed.connect(func() -> void:
		NavManager.set_time_scale(1.0)
	)
	btn_speed_3x.pressed.connect(func() -> void:
		NavManager.set_time_scale(3.0)
	)
	btn_speed_5x.pressed.connect(func() -> void:
		NavManager.set_time_scale(5.0)
	)


func _setup_anchor_button() -> void:
	btn_anchor_toggle.pressed.connect(_on_anchor_toggled)
	# Initial label based on current state
	var anchored: bool = NavManager.is_anchored
	btn_anchor_toggle.text = "Lift Anchor" if anchored else "Drop Anchor"


func _set_city_marker_position() -> void:
	# For now, just a fixed position; later you can map world coords
	city_marker.position = Vector2(50.0, 100.0)


@warning_ignore("unused_parameter")
func _on_nav_position_changed(true_pos: Vector2, est_pos: Vector2, error_radius: float) -> void:
	_update_ship_marker(est_pos)
	_update_log_pose(true_pos)
	# Later: also update a visual for error_radius (uncertainty circle)


func _update_ship_marker(est_pos: Vector2) -> void:
	var map_pos: Vector2 = est_pos * MAP_SCALE + MAP_OFFSET
	ship_marker.position = map_pos

func _update_log_pose(ship_pos: Vector2) -> void:
	var to_target: Vector2 = log_pose_target_pos - ship_pos
	if to_target.length() < 0.001:
		return  # we're basically on top of it, avoid NaN nonsense

	# Angle in radians from +X axis (east) to our target vector
	var angle_rad: float = atan2(to_target.y, to_target.x)

	# Godot 2D rotation uses radians; if your needle texture points to the right by default,
	# this is enough. If you drew it pointing up, you need to subtract 90 degrees.
	log_pose_needle.rotation = angle_rad + deg_to_rad(90.0)


func _on_anchor_toggled() -> void:
	var now_anchored: bool = not NavManager.is_anchored
	NavManager.set_anchored(now_anchored)
	btn_anchor_toggle.text = "Lift Anchor" if now_anchored else "Drop Anchor"


func _highlight_marker_for_region(id: String) -> void:
	# Minimal stub so your connection works without errors.
	# You can expand this based on your actual regions.
	if id == "capital":
		# Example: flash or emphasize city marker
		city_marker.modulate = Color(1, 1, 1)  # or some highlight color
		# Later you could animate, etc.
