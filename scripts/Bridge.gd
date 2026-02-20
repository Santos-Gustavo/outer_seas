
extends Control

@onready var map_view: Control   = %MapView
@onready var event_view: Control = %EventView
@onready var log_view: Control   = %LogView
@onready var crew_view: Control  = %CrewView
@onready var tool_view: Control  = %ToolsView
@onready var battle_view: Control  = %BattleView

@onready var btn_map: Button     = %MapButton
@onready var btn_events: Button  = %EventsButton
@onready var btn_log: Button     = %LogButton
@onready var btn_crew: Button    = %CrewButton
@onready var btn_tools: Button   = %ToolsButton
@onready var btn_battle: Button   = %BattleButton

var _views: Dictionary
var _buttons: Dictionary

func _ready() -> void:
	_init_views_and_buttons()

	# Button wiring
	btn_map.pressed.connect(func() -> void:
		_set_active_view("map")
	)
	btn_events.pressed.connect(func() -> void:
		_set_active_view("event")
	)
	btn_log.pressed.connect(func() -> void:
		_set_active_view("log")
	)
	btn_crew.pressed.connect(func() -> void:
		_set_active_view("crew")
	)
	btn_tools.pressed.connect(func() -> void:
		_set_active_view("tools")
	)
	btn_battle.pressed.connect(func() -> void:
		_set_active_view("battle")
	)

	# Auto-switch to Event view when an event starts
	EventManager.event_started.connect(func(_id: String) -> void:
		_set_active_view("event")
	)

	# Initial view
	_set_active_view("map")


func _init_views_and_buttons() -> void:
	_views = {
		"map": map_view,
		"event": event_view,
		"log": log_view,
		"crew": crew_view,
		"tools": tool_view,
		"battle": battle_view
	}

	_buttons = {
		"map": btn_map,
		"event": btn_events,
		"log": btn_log,
		"crew": btn_crew,
		"tools": btn_tools,
		"battle": btn_battle
	}


func _set_active_view(id: String) -> void:
	# Views: only the chosen one is visible
	for key in _views.keys():
		var view: Control = _views[key]
		view.visible = (key == id)

	# Buttons: only the chosen one appears pressed
	for key in _buttons.keys():
		var btn: Button = _buttons[key]
		btn.button_pressed = (key == id)
