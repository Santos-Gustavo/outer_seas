extends Control

@onready var player_name: RichTextLabel = %PlayerName
@onready var player_hp: ProgressBar = %PlayerHP


@onready var player_position: Control = %PlayerPosition
@onready var player_fire_policy: Control = %PlayerFirePolicy
@onready var player_range: Control = %PlayerRange
@onready var player_aggressivity: Control = %PlayerAggressivity
@onready var player_aim_focus: Control = %PlayerAimFocus


@onready var enemy_attack_choices: Control = %EnemyAttackChoices
@onready var enemy_position_choices: Control = %EnemyPositionChoices


const POSITIONS := ["Parallel", "Rake", "Chase", "Head-on", "Disengaging"]
const FIRE_POLICY := ["Accurate", "Balanced", "Fire-at-will"]
const RANGE := ["Far", "Medium", "Close"]
const AGGRESSITVITY := ["Ultra Defensive", "Defensive", "Balanced", "Aggressive", "Ultra Aggressive"]
const AIM_FOCUS := ["Mast", "Rudder", "Crow's Nest", "Gunport", "Bow Chaser"]


var p_name := "Luffy"

func _ready() -> void:
	_connect_signals_once()
	_init_static_ui()

func _connect_signals_once() -> void:
	if not CrewManager.crew_hp.is_connected(_on_crew_connect):
		CrewManager.crew_hp.connect(_on_crew_connect)

func _init_static_ui() -> void:
	player_name.text = p_name
	CrewManager.request_crew_hp()

	_build_choice_buttons()

func _build_choice_buttons() -> void:
	_clear_children(player_fire_policy)
	_clear_children(player_position)
	
	_clear_children(enemy_attack_choices)
	_clear_children(enemy_position_choices)

	for pos in POSITIONS:
		_add_button(player_position, pos, func(): _on_position_chosen(pos))
		_add_button(enemy_position_choices, pos, func(): _on_position_chosen(pos)) # optional / later

	for act in FIRE_POLICY:
		_add_button(player_fire_policy, act, func(): _on_action_chosen(act))
		_add_button(enemy_attack_choices, act, func(): _on_action_chosen(act)) # optional / later
		
	for rang in RANGE:
		_add_button(player_range, rang, func(): _on_action_chosen(rang))
		#_add_button(enemy_attack_choices, rang, func(): _on_action_chosen(act)) # optional / later

	for agress in AGGRESSITVITY:
		_add_button(player_aggressivity, agress, func(): _on_action_chosen(agress))
		#_add_button(enemy_attack_choices, act, func(): _on_action_chosen(act)) # optional / later


func _on_crew_connect(maxv: float, minv: float, currentv: float) -> void:
	player_hp.min_value = minv
	player_hp.max_value = maxv
	player_hp.value = currentv

func _clear_children(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()

func _add_button(container: Node, text: String, function: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(function)
	container.add_child(button)

func _on_action_chosen(action_choose: String) -> void:
	BattleManager.choose_action(action_choose) # "Attack"/"Defend"

func _on_position_chosen(position_choose: String) -> void:
	BattleManager.choose_position(position_choose)



















#extends Node
#
#@onready var player_name := $MarginContainer/VBoxContainer/HBoxContainer/PlayerContainer/PlayerInfo/Name
#@onready var player_hp : ProgressBar = $MarginContainer/VBoxContainer/HBoxContainer/PlayerContainer/PlayerInfo/HP
#
#
#@onready var player_position := $MarginContainer/VBoxContainer/HBoxContainer/PlayerContainer/Choices/Position
#
#@onready var player_attack := $MarginContainer/VBoxContainer/HBoxContainer/PlayerContainer/Choices/Attack
#@onready var enemy_choices := $MarginContainer/VBoxContainer/HBoxContainer/EnemyContainer/Choices
#
#var p_name = "Luffy"
#
#
#func _ready() -> void:
	#if not CrewManager.crew_hp.is_connected(_on_crew_connect):
		#CrewManager.crew_hp.connect(_on_crew_connect)
#
	#CrewManager.request_crew_hp()
	#
	#var current := BattleManager.current_battle()
	#_on_current_event_changed(current)
#
#
#func _on_current_event_changed(text) -> void:
	#_populate_choices()
#
#
#func _populate_choices():
	#var screens_atk = [player_attack, enemy_choices]
	#var screens_pos = [player_position, enemy_choices]
	#player_name.add_text(p_name)
#
	#for screen in screens_atk:
		#_clear_choices(screen)
		#_add_attack_button("Attack", screen)
		#_add_attack_button("Deffend", screen)
	#
	#for screen in screens_pos:
		#_clear_choices(screen)
		#_add_position_button("Parallel", screen)
		#_add_position_button("Rake", screen)
		#_add_position_button("Chase", screen)
		#_add_position_button("Head-on", screen)
		#_add_position_button("Disengaging", screen)
#
	#
#func _on_crew_connect(maxv, minv, currentv):
	#player_hp.max_value = maxv
	#player_hp.min_value = minv
	#player_hp.value = currentv
	#
	#
#func _clear_choices(screen) -> void:
	#for child in screen.get_children():
		#child.queue_free()
#
#func _add_position_button(text, screen) -> void:
	#var button := Button.new()
	#button.text = text
	#screen.add_child(button)
	#button.pressed.connect(_on_position_pressed)
#
#func _add_attack_button(text, screen) -> void:
	#var button := Button.new()
	#button.text = text
	#screen.add_child(button)
	#button.pressed.connect(_on_attack_pressed)
#
#
#func _on_attack_pressed():
	#BattleManager.attack()
	#
#func _on_position_pressed():
	#BattleManager.position()
