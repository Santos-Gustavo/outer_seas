extends Control


@onready var map_viewport: Control   = %MapViewport
@onready var map_content: Control    = %MapContent
@onready var map_texture: TextureRect = %MapTexture

@onready var ship_marker: Control = %ShipMarker
@onready var city_marker: Control = %CityMarker
@onready var log_pose_needle: TextureRect = %Needle
@onready var uncertainty_overlay: Control  = %UncertaintyOverlay

@onready var nav_log: NavLogPanel = %NavLogPanel

@onready var btn_heading_east: Button  = %TravelEast100Button
@onready var btn_heading_south: Button = %TravelSouth100Button
@onready var btn_heading_west: Button  = %TravelWest100Button
@onready var btn_heading_north: Button = %TravelNorth100Button


@onready var btn_anchor_toggle: Button = %AnchorToggleButton
@onready var btn_speed_0x: Button      = %Speed0xButton
@onready var btn_speed_1x: Button      = %Speed1xButton
@onready var btn_speed_3x: Button      = %Speed3xButton
@onready var btn_speed_5x: Button      = %Speed5xButton
@onready var btn_spyglass: Button      = %UseSpyglassButton

# Simple conversion from world coords (km) to map coords (pixels)

var log_pose_target_pos: Vector2 = Vector2(320, 120)  # same as your ashfall center
var log_pose_target_id: String = "ashfall"
const WORLD_ORIGIN_PIXELS: Vector2 = Vector2(0.0, 0.0)
const MAP_SCALE: float = 0.2
const MAP_OFFSET: Vector2 = Vector2(50.0, 0.0)
const BASE_MAP_SCALE: float = 1.0
var MAP_ZOOM: float = 5  # 1.0 = normal, 2.0 = 2x zoom-in, 0.5 = zoom-out


func _ready() -> void:
	# Listen to navigation updates
	print("MAP_ZOOM at startup: ", MAP_ZOOM)
	NavManager.position_changed.connect(_on_nav_position_changed)

	# Heading / speed / anchor controls
	_setup_heading_controls()
	_setup_speed_controls()
	_setup_anchor_button()
	
	btn_spyglass.pressed.connect(func() -> void:
		ToolManager.use_spyglass()
	)

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


func _update_map_window(est_pos: Vector2) -> void:
	MAP_ZOOM = clamp(MAP_ZOOM, 0.5, 8.0)
	var effective_scale: float = BASE_MAP_SCALE * MAP_ZOOM

	# world → map (zoomed) coordinates
	var ship_map_pos: Vector2 = est_pos * effective_scale + WORLD_ORIGIN_PIXELS

	var viewport_center: Vector2 = map_viewport.size / 2.0

	# ship drawn in center of the viewport
	ship_marker.position = viewport_center

	# scale the whole map (texture + markers) by MAP_ZOOM
	map_content.scale = Vector2(MAP_ZOOM, MAP_ZOOM)

	# position the scaled map so that ship_map_pos ends up under viewport_center
	var map_offset: Vector2 = viewport_center - ship_map_pos
	map_content.position = map_offset


func _setup_anchor_button() -> void:
	btn_anchor_toggle.pressed.connect(_on_anchor_toggled)
	# Initial label based on current state
	var anchored: bool = NavManager.is_anchored
	btn_anchor_toggle.text = "Lift Anchor" if anchored else "Drop Anchor"


func _set_city_marker_position() -> void:
	# For now, just a fixed position; later you can map world coords
	city_marker.position = Vector2(50.0, 100.0)


func _on_nav_position_changed(true_pos: Vector2, est_pos: Vector2, error_radius: float) -> void:
	_update_map_window(est_pos)
	_update_log_pose(true_pos)
	_update_uncertainty(error_radius)


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


func _update_uncertainty(error_radius_world: float) -> void:
	# Ship is always drawn at the viewport center in our current design
	var viewport_center: Vector2 = map_viewport.size / 2

	# Convert world units (km-equivalent) to pixels: same mapping as est_pos
	var effective_scale: float = BASE_MAP_SCALE * MAP_ZOOM
	var radius_px: float = error_radius_world * effective_scale

	uncertainty_overlay.update_circle(viewport_center, radius_px)


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
