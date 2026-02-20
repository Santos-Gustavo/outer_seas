extends Node

@onready var player_screen := $MarginContainer/VBoxContainer/HBoxContainer/PlayerContainer
@onready var enemy_screen := $MarginContainer/VBoxContainer/HBoxContainer/EnemyContainer


func _ready() -> void:
	BattleManager.current_battle_change.connect(_on_current_event_changed)
	
	var current := BattleManager.current_battle()
	_on_current_event_changed(current)


func _on_current_event_changed(text) -> void:
	print(text)
	_populate_choices()


func _populate_choices():
	var screens = [player_screen, enemy_screen]
	for screen in screens:
		_clear_choices(screen)
		_add_choice_button("Attack", screen)
		_add_choice_button("Deffend", screen)


func _clear_choices(screen) -> void:
	for child in screen.get_children():
		child.queue_free()


func _add_choice_button(text, screen) -> void:
	var button := Button.new()
	button.text = text
	screen.add_child(button)
	
