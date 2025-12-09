extends Control

@onready var lbl_location := $MarginContainer/VBoxContainer/LocationLabel
@onready var lbl_text := $MarginContainer/VBoxContainer/EventText
@onready var choices_box := $MarginContainer/VBoxContainer/Choices


func _ready() -> void:
	# Listen for event changes
	EventManager.current_event_changed.connect(_on_current_event_changed)

	# For now, start the first story event when this view loads
	var current := EventManager.get_current_event()
	if not current.is_empty():
		_on_current_event_changed(current)


func _on_current_event_changed(event: Dictionary) -> void:
	_show_event(event)


func _show_event(event: Dictionary) -> void:
	# Clear old UI
	for child in choices_box.get_children():
		child.queue_free()

	if event.is_empty():
		lbl_location.text = "No active event"
		lbl_text.text = ""
		return

	lbl_location.text = event.get("location", "Unknown location")
	var text_lines: Array = event.get("text", [])
	lbl_text.text = "\n\n".join(text_lines)

	var choices: Array = event.get("choices", [])
	for c in choices:
		_add_choice_button(c)


func _add_choice_button(choice: Dictionary) -> void:
	var btn := Button.new()
	btn.text = choice.get("label", "Choice")
	var choice_id: String = choice.get("id", "")
	btn.pressed.connect(func():
		EventManager.choose(choice_id)
		_show_choice_outcome(choice)
	)
	choices_box.add_child(btn)


func _show_choice_outcome(choice: Dictionary) -> void:
	# Show outcome text after a choice; then EventManager will move to next event,
	# and _on_current_event_changed will update when that happens.
	var outcome: Array = choice.get("outcome_text", [])
	if outcome.size() > 0:
		lbl_text.text = "\n\n".join(outcome)
