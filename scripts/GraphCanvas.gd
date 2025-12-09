
extends Control

var graph_data: Dictionary = {}        # raw dictionary from JSON / LogView
var nodes: Dictionary = {}             # id -> { "entry": Dictionary, "button": Button }
var edges: Array = []                  # [id_a, id_b]


func set_graph_data(new_data: Dictionary) -> void:
	# 1) Store data
	graph_data = new_data
	# 2) Rebuild the visual graph
	_rebuild_graph()


func _rebuild_graph() -> void:
	_clear_graph()
	_build_nodes()
	_build_edges()
	queue_redraw()


func _clear_graph() -> void:
	for child in get_children():
		child.queue_free()
	nodes.clear()
	edges.clear()


func _build_nodes() -> void:
	for id in graph_data.keys():
		var entry: Dictionary = graph_data[id]

		# Only create a visual node for discovered entries
		if not entry.has("discovered") or not entry["discovered"]:
			continue

		var btn := Button.new()
		#if not entry.has("rumor") or entry["rumor"]:
			#btn.text = "Unknow Node"
		#else:
		btn.text = entry["title"]
		
		btn.position = entry["pos"] if entry.has("pos") else Vector2.ZERO
		btn.toggle_mode = true
		add_child(btn)

		nodes[id] = {
			"entry": entry,
			"button": btn
		}


func _build_edges() -> void:
	for id in nodes.keys():
		var entry: Dictionary = nodes[id]["entry"]
		if not entry.has("links"):
			continue

		for link_id in entry["links"]:
			# Only draw edges between nodes that actually exist (discovered)
			if nodes.has(link_id):
				edges.append([id, link_id])


func _draw() -> void:
	for edge in edges:
		var id_a = edge[0]
		var id_b = edge[1]
		if not nodes.has(id_a) or not nodes.has(id_b):
			continue

		var btn_a: Button = nodes[id_a]["button"]
		var btn_b: Button = nodes[id_b]["button"]

		var a_center: Vector2 = btn_a.position + btn_a.size * 0.5
		var b_center: Vector2 = btn_b.position + btn_b.size * 0.5

		draw_line(a_center, b_center, Color(0.6, 0.7, 0.9), 2.0)
