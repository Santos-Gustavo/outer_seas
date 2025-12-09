extends Node

const locations := {
	"capital": Vector2(0, 0),
	"ashfall": Vector2(320, -120),
	"storm_edge": Vector2(600, 50),
}

static func get_position(id: String) -> Vector2:
	if locations.has(id):
		return locations[id]
	push_warning("WorldLocations: unknown location id '%s'" % id)
	return Vector2.ZERO
