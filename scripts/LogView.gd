extends Control

@onready var graph_canvas := $MarginContainer/HBoxContainer/GraphPanel/ScrollContainer/GraphCanvas
@onready var lbl_title := $MarginContainer/HBoxContainer/DetailsPanel/EntryTitle
@onready var lbl_body := $MarginContainer/HBoxContainer/DetailsPanel/EntryBody

var log_graph_data: Dictionary = {}


func _ready() -> void:
	LogManager.log_changed.connect(_refresh_graph)
	_refresh_graph()
	_clear_details()

func _refresh_graph() -> void:
	graph_canvas.set_graph_data(LogManager.log_graph_data)
	_connect_node_signals()


func _connect_node_signals() -> void:
	for id in LogManager.log_graph_data.keys():
		if not graph_canvas.nodes.has(id):
			continue
		var node_info: Dictionary = graph_canvas.nodes[id]
		var btn: Button = node_info["button"]
		btn.pressed.connect(func(): _on_node_pressed(id))


func _load_log_graph() -> void:
	var path := "res://data/log_graph.json"
	if not FileAccess.file_exists(path):
		push_error("Log graph JSON not found at: " + path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	var raw := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Failed to parse log graph JSON.")
		return

	log_graph_data = parsed
	_convert_positions()


func _convert_positions() -> void:
	for id in log_graph_data.keys():
		var entry: Dictionary = log_graph_data[id]
		if entry.has("pos") and entry["pos"] is Array and entry["pos"].size() == 2:
			var arr: Array = entry["pos"]
			entry["pos"] = Vector2(arr[0], arr[1])


func get_title_and_text(entry) -> void:
	lbl_title.text = entry["title"]
	var body_dict: Dictionary = entry["text"]
	var body_text := ""
	
	for sentence in body_dict.keys():
		if body_dict[sentence]:
			body_text += sentence + "\n"

	lbl_body.text = body_text


func _on_node_pressed(id: String) -> void:
	if not LogManager.log_graph_data.has(id):
		return

	var entry: Dictionary = LogManager.log_graph_data[id]
	#if not entry.has("rumor") or entry["rumor"]:
		#lbl_title.text = "Unknown node"
		#lbl_body.text = "You haven't uncovered this yet."
		#return
	get_title_and_text(entry)


func _clear_details() -> void:
	lbl_title.text = "World Log"
	lbl_body.text = "Select a node to see details."
