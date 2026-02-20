extends Node

var regions: Array = []

const locations := {
	"capital": Vector2(50, 100),
	"ashfall": Vector2(320, -120),
	"storm_edge": Vector2(600, 50),
}

func _ready():
	_init_regions()

func get_position(id: String) -> Vector2:
	if locations.has(id):
		return locations[id]
	push_warning("WorldLocations: unknown location id '%s'" % id)
	return Vector2.ZERO


func _init_regions() -> void:
	regions = [
		{
			"id": "capital",
			"type": "island",
			"shape": "circle",
			"center": get_position("capital"),
			"radius": 200.0,
			"event_on_enter": "cap_dock_arrival",
			"hidden_event": true
		},
		{
			"id": "ashfall",
			"type": "island",
			"shape": "circle",
			"center": get_position("ashfall"),
			"radius": 60.0,
			"event_on_enter": "ash_dock_tension",
			"hidden_event": true
		},
		{
			"id": "storm_edge",
			"type": "hazard",
			"shape": "circle",
			"center": get_position("storm_edge"),
			"radius": 120.0,
			"event_on_enter": "storm_edge_scan",
			"hidden_event": true
		}
	]
