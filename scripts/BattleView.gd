extends Node

@onready var player_name := $MarginContainer/VBoxContainer/HBoxContainer/PlayerContainer/PlayerInfo/Name
@onready var player_hp : ProgressBar = $MarginContainer/VBoxContainer/HBoxContainer/PlayerContainer/PlayerInfo/HP

@onready var player_choices := $MarginContainer/VBoxContainer/HBoxContainer/PlayerContainer/Choices
@onready var enemy_choices := $MarginContainer/VBoxContainer/HBoxContainer/EnemyContainer/Choices

var p_name = "Luffy"



func _ready() -> void:
	BattleManager.current_battle_change.connect(_on_current_event_changed)
	
	var current := BattleManager.current_battle()
	_on_current_event_changed(current)


func _on_current_event_changed(text) -> void:
	print(text)
	_populate_choices()


func _populate_choices():
	var screens = [player_choices, enemy_choices]
	player_name.add_text(p_name)
	
	CrewManager.crew_hp.connect(_on_crew_connect)
	CrewManager.request_crew_hp()

	for screen in screens:
		_clear_choices(screen)
		_add_choice_button("Attack", screen)
		_add_choice_button("Deffend", screen)

	
func _on_crew_connect(maxv, minv, currentv):
	player_hp.max_value = maxv
	player_hp.min_value = minv
	player_hp.value = currentv
	
	
func _clear_choices(screen) -> void:
	for child in screen.get_children():
		child.queue_free()


func _add_choice_button(text, screen) -> void:
	var button := Button.new()
	button.text = text
	screen.add_child(button)
	button.pressed.connect(_on_attack_pressed)


func _on_attack_pressed():
	BattleManager.attack(5)
	
