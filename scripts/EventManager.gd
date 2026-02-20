extends Node
#class_name Event_Manager

signal event_started(event_id: String)
signal event_finished(event_id: String)
signal current_event_changed(event: Dictionary)
signal log_updates_requested(updates: Array)

var events: Dictionary = {}           # id -> event dictionary
var flags: Dictionary = {}            # name -> bool
var seen_events: Dictionary = {}      # id -> bool
var current_event_id: String = ""


func _ready() -> void:
	_load_events()


# -------------------------------------------------------------------
# Loading
# -------------------------------------------------------------------

func _load_events() -> void:
	var path := "res://data/events.json"
	if not FileAccess.file_exists(path):
		push_error("EventManager: events.json not found at " + path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	var raw := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("EventManager: failed to parse events.json")
		return

	var root: Dictionary = parsed
	if not root.has("events"):
		push_error("EventManager: 'events' key missing in JSON")
		return

	var raw_events: Dictionary = root["events"]
	events.clear()
	for id in raw_events.keys():
		var e: Dictionary = raw_events[id]
		print(e)
		# Ensure id is set inside each event
		e["id"] = id
		events[id] = e


# -------------------------------------------------------------------
# Event access
# -------------------------------------------------------------------

func get_current_event() -> Dictionary:
	if current_event_id == "" or not events.has(current_event_id):
		return {}
	return events[current_event_id]


func has_event(event_id: String) -> bool:
	return events.has(event_id)


func is_event_seen(event_id: String) -> bool:
	return seen_events.get(event_id, false)


# -------------------------------------------------------------------
# Flags
# -------------------------------------------------------------------

func set_flag(name_set_flag: String, value: bool = true) -> void:
	flags[name_set_flag] = value


func clear_flag(name_flag: String) -> void:
	flags.erase(name_flag)


func has_flag(name_has_flag: String) -> bool:
	return flags.get(name_has_flag, false)


# -------------------------------------------------------------------
# Starting / selecting events
# -------------------------------------------------------------------

func start_event(event_id: String) -> void:
	NavManager.set_time_scale(0.0)
	if not events.has(event_id):
		push_error("EventManager: no event with id '%s'" % event_id)
		return

	current_event_id = event_id
	seen_events[event_id] = true
	event_started.emit(event_id)
	current_event_changed.emit(events[event_id])


func start_first_event() -> void:
	# Look for an event whose triggers include "start"
	for id in events.keys():
		var e: Dictionary = events[id]
		var triggers: Array = e.get("triggers", [])
		if "start" in triggers:
			start_event(id)
			return

	push_error("EventManager: no event with 'start' trigger found")


func find_events_for_trigger(trigger_tag: String, location: String = "") -> Array:
	var result: Array = []
	for id in events.keys():
		var e: Dictionary = events[id]
		var once: bool = e.get("once", true)
		if once and is_event_seen(id):
			continue

		var triggers: Array = e.get("triggers", [])
		if trigger_tag in triggers:
			if location == "" or e.get("location", "") == location:
				result.append(e)
	return result


# -------------------------------------------------------------------
# Choosing options / advancing
# -------------------------------------------------------------------

func choose(choice_id: String) -> void:
	var current: Dictionary = get_current_event()
	if current.is_empty():
		push_warning("EventManager: choose() called but no current event")
		return

	var choices: Array = current.get("choices", [])
	var chosen: Dictionary = {}
	for c in choices:
		if c.get("id", "") == choice_id:
			chosen = c
			break

	if chosen.is_empty():
		push_warning("EventManager: choice '%s' not found in event '%s'" % [choice_id, current_event_id])
		return

	_apply_choice_consequences(current, chosen)


func _apply_choice_consequences(event: Dictionary, choice: Dictionary) -> void:
	_apply_flags_from_choice(choice)
	_emit_log_updates(choice)
	_advance_event(event, choice)


func _apply_flags_from_choice(choice: Dictionary) -> void:
	var to_set: Array = choice.get("set_flags", [])
	for names in to_set:
		set_flag(names, true)

	var to_clear: Array = choice.get("clear_flags", [])
	for names in to_clear:
		clear_flag(names)


func _emit_log_updates(choice: Dictionary) -> void:
	var updates = choice.get("log_updates", [])
	if updates is Array and updates.size() > 0:
		log_updates_requested.emit(updates)


func _advance_event(event: Dictionary, choice: Dictionary) -> void:
	var prev_id: String = event.get("id", "") as String
	event_finished.emit(prev_id)
	
	var next_id = choice.get("next_event", "")
	
	if next_id == "" or next_id == "null" or next_id == null:
		current_event_id = ""
		current_event_changed.emit({})
		return

	if not events.has(next_id):
		push_error("EventManager: next_event '%s' not found" % next_id)
		current_event_id = ""
		current_event_changed.emit({})
		return

	current_event_id = next_id
	seen_events[next_id] = true
	event_started.emit(next_id)
	current_event_changed.emit(events[next_id])
