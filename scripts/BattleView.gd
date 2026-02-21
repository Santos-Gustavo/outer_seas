extends Control

@onready var player_name: RichTextLabel = %PlayerName
@onready var player_hp: ProgressBar = %PlayerHP
@onready var end_turn: Button = %Combat


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
const AIM_FOCUS := ["Hull", "Mast", "Rudder", "Crow's Nest", "Gunport", "Bow Chaser"]


var p_name := "Luffy"

func _ready() -> void:
	_connect_signals_once()
	_init_static_ui()

func _connect_signals_once() -> void:
	if not CrewManager.crew_hp_changed.is_connected(_on_crew_hp_changed):
		CrewManager.crew_hp_changed.connect(_on_crew_hp_changed)

func _on_crew_hp_changed(maxv: float, minv: float, currentv: float) -> void:
	player_hp.min_value = minv
	player_hp.max_value = maxv
	player_hp.value = currentv
	
func _init_static_ui() -> void:
	player_name.text = p_name
	_on_crew_hp_changed(100.0, 0.0, CrewManager.get_boat_integrity())

	_build_choice_buttons()
	end_turn.pressed.connect(_on_end_turn_pressed)


func _on_end_turn_pressed() -> void:
	BattleManager.resolve_round()


func _build_choice_buttons() -> void:
	_clear_children(player_fire_policy)
	_clear_children(player_position)
	
	_clear_children(enemy_attack_choices)
	_clear_children(enemy_position_choices)

	for pos in POSITIONS:
		_add_button(player_position, pos, func(): _on_position_chosen(pos))
		_add_button(enemy_position_choices, pos, func(): _on_position_chosen(pos)) # optional / later

	for act in FIRE_POLICY:
		_add_button(player_fire_policy, act, func(): _on_fire_policy_chosen(act))
		_add_button(enemy_attack_choices, act, func(): _on_fire_policy_chosen(act)) # optional / later
		
	for rang in RANGE:
		_add_button(player_range, rang, func(): _on_range_chosen(rang))
		#_add_button(enemy_attack_choices, rang, func(): _on_action_chosen(act)) # optional / later

	for agress in AGGRESSITVITY:
		_add_button(player_aggressivity, agress, func(): _on_aggressivity_chosen(agress))
		#_add_button(enemy_attack_choices, act, func(): _on_action_chosen(act)) # optional / later
		
	for aim in AIM_FOCUS:
		_add_button(player_aim_focus, aim, func(): _on_aim_policy_chosen(aim))


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
	button.focus_entered.connect(function)
	container.add_child(button)


func _on_position_chosen(choice: String) -> void:
	BattleManager.choose_position(choice)

func _on_fire_policy_chosen(choice: String) -> void:
	BattleManager.choose_fire_policy(choice)

func _on_range_chosen(choice: String) -> void:
	BattleManager.choose_range(choice)

func _on_aggressivity_chosen(choice: String) -> void:
	BattleManager.choose_aggressivity(choice)

func _on_aim_policy_chosen(choice: String) -> void:
	BattleManager.choose_aim_policy(choice)
