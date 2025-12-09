extends Control
class_name UncertaintyOverlay

var _center: Vector2 = Vector2.ZERO
var _radius_px: float = 0.0

@export var fill_color: Color = Color(0.8, 0.8, 1.0, 0.12)
@export var line_color: Color = Color(0.8, 0.8, 1.0, 0.6)
@export var line_width: float = 2.0


func update_circle(center_in_viewport: Vector2, radius_px: float) -> void:
	_center = center_in_viewport
	_radius_px = max(radius_px, 0.0)
	queue_redraw()


func clear_circle() -> void:
	_radius_px = 0.0
	queue_redraw()


func _draw() -> void:
	if _radius_px <= 1.0:
		return

	# Fill
	draw_circle(_center, _radius_px, fill_color)
	# Outline
	draw_arc(_center, _radius_px, 0.0, TAU, 64, line_color, line_width)
