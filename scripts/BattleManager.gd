extends Control
#class_name Battle_Manager

signal current_battle_change(battle: Dictionary)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_battle_change.emit({"test3": "test4"})




func start_battle():
	NavManager.set_time_scale(0.0)
	
	#for child in player_screen.get_children():
		#child.queue_free()
	
	#var choices: Array = event.get("choices", [])
	#for c in choices:
	current_battle_change.emit({"test": "test1"})
		

func current_battle() -> String:
	return "Aloha"

#
#
#
#func _add_choice_button(choice: Dictionary) -> void:
	#var btn := Button.new()
	#btn.text = choice.get("label", "Choice")
	#var choice_id: String = choice.get("id", "")
	#btn.pressed.connect(func():
		#EventManager.choose(choice_id)
		#_show_choice_outcome(choice)
	#)
	#choices_box.add_child(btn)
#
## -------------------------------------------------------------------
## Choosing options / advancing
## -------------------------------------------------------------------
#
#func choose(choice_id: String) -> void:
	#var current: Dictionary = get_current_event()
	#if current.is_empty():
		#push_warning("EventManager: choose() called but no current event")
		#return
#
	#var choices: Array = current.get("choices", [])
	#var chosen: Dictionary = {}
	#for c in choices:
		#if c.get("id", "") == choice_id:
			#chosen = c
			#break
#
	#if chosen.is_empty():
		#push_warning("EventManager: choice '%s' not found in event '%s'" % [choice_id, current_event_id])
		#return
#
	#_apply_choice_consequences(current, chosen)
#
#
#func _apply_choice_consequences(event: Dictionary, choice: Dictionary) -> void:
	#_apply_flags_from_choice(choice)
	#_emit_log_updates(choice)
	#_advance_event(event, choice)
#
#
#func _apply_flags_from_choice(choice: Dictionary) -> void:
	#var to_set: Array = choice.get("set_flags", [])
	#for names in to_set:
		#set_flag(names, true)
#
	#var to_clear: Array = choice.get("clear_flags", [])
	#for names in to_clear:
		#clear_flag(names)
#
#
#func _emit_log_updates(choice: Dictionary) -> void:
	#var updates = choice.get("log_updates", [])
	#if updates is Array and updates.size() > 0:
		#log_updates_requested.emit(updates)
#
#
#func _advance_event(event: Dictionary, choice: Dictionary) -> void:
	#var prev_id: String = event.get("id", "") as String
	#event_finished.emit(prev_id)
	#
	#var next_id = choice.get("next_event", "")
	#
	#if next_id == "" or next_id == "null" or next_id == null:
		#current_event_id = ""
		#current_event_changed.emit({})
		#return
#
	#if not events.has(next_id):
		#push_error("EventManager: next_event '%s' not found" % next_id)
		#current_event_id = ""
		#current_event_changed.emit({})
		#return
#
	#current_event_id = next_id
	#seen_events[next_id] = true
	#event_started.emit(next_id)
	#current_event_changed.emit(events[next_id])
