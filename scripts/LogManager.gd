extends Node
class_name Log_Manager

var log_graph_data: Dictionary = {}    # same structure as your log_graph.json

signal log_changed()


func _ready() -> void:
	_load_log_graph()
	# Listen to EventManager log updates
	EventManager.log_updates_requested.connect(apply_updates)


func _load_log_graph() -> void:
	var path := "res://data/log_graph.json"
	if not FileAccess.file_exists(path):
		push_error("LogManager: log_graph.json not found at " + path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	var raw := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("LogManager: failed to parse log_graph.json")
		return

	log_graph_data = parsed

	# Convert pos arrays to Vector2
	for id in log_graph_data.keys():
		var entry: Dictionary = log_graph_data[id]
		if entry.has("pos") and entry["pos"] is Array and entry["pos"].size() == 2:
			var arr: Array = entry["pos"]
			entry["pos"] = Vector2(arr[0], arr[1])


func apply_updates(updates: Array) -> void:
	# Each update: { entry_id, discovered, rumor }
	for u in updates:
		var entry_id: String = u.get("entry_id", "")
		if entry_id == "" or not log_graph_data.has(entry_id):
			continue

		var entry: Dictionary = log_graph_data[entry_id]
		if u.has("discovered"):
			entry["discovered"] = u["discovered"]
		if u.has("rumor"):
			entry["rumor"] = u["rumor"]

	log_changed.emit()
