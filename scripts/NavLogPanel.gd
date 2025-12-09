extends Control
class_name NavLogPanel

@onready var log_label: RichTextLabel = $PanelContainer/MarginContainer/ScrollContainer/LogLabel
@onready var scroll: ScrollContainer = $PanelContainer/MarginContainer/ScrollContainer

const MAX_LINES: int = 100

var _lines: Array[String] = []

var last_day_km := NavManager.get_distance_travelled_last_day()
var today_km := NavManager.get_distance_travelled_current_day()

func _ready() -> void:
	# Subscribe to nav messages
	NavManager.nav_message.connect(_on_nav_message)
	NavManager.day_finished.connect(func(day_index: int, dist: float) -> void:
		NavManager.nav_message.emit("Day %d complete. Sailed %.0f km." % [day_index, dist])
	)

	_clear_log()


func _on_nav_message(text: String) -> void:
	_add_line(text)


func _add_line(text: String) -> void:
	# Store line
	_lines.append(text)

	# Truncate if too long
	if _lines.size() > MAX_LINES:
		_lines.pop_front()

	# Rebuild label text (simple and clear)
	log_label.text = "\n".join(_lines)

	# Scroll to bottom
	await get_tree().process_frame
	_scroll_to_bottom()


func _scroll_to_bottom() -> void:
	var v_scroll := scroll.get_v_scroll_bar()
	v_scroll.value = v_scroll.max_value


func _clear_log() -> void:
	_lines.clear()
	log_label.text = ""
