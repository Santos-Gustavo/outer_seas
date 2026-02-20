extends Control

signal battle_started(battle_id: String)
signal battle_finished(event_id: String)
signal current_battle_changed(battle: Dictionary)

var player_helmsmanship
var player_sail_handling
var player_gunnery
var player_reload
var player_damage_control
var player_recon


var enemy_helmsmanship
var enemy_sail_handling
var enemy_gunnery
var enemy_reload
var enemy_damage_control
var enemy_recon




func _ready() -> void:
	current_battle_changed.emit({"test3": "test4"})

	CrewManager.crew_status.connect(_on_player_crew_status)
	CrewManager.crew_status.connect(_on_enemy_crew_status)
	CrewManager.request_crew_status()


func _on_player_crew_status(helmsmanship, sail_handling, gunnery, reload, damage_control, recon):
	player_helmsmanship = helmsmanship
	player_sail_handling = sail_handling
	player_gunnery = gunnery
	player_reload = reload
	player_damage_control = damage_control
	player_recon = recon



func _on_enemy_crew_status(helmsmanship, sail_handling, gunnery, reload, damage_control, recon):
	enemy_helmsmanship = helmsmanship
	enemy_sail_handling = sail_handling
	enemy_gunnery = gunnery
	enemy_reload = reload
	enemy_damage_control = damage_control
	enemy_recon = recon


func start_battle():
	print("Starting battle")
	NavManager.set_time_scale(0.0)
	battle_started.emit("battle")
	current_battle_changed.emit(battle_started)


func current_battle() -> String:
	return "Aloha"


func choose_action(action):
	print("Player attack: ", action)
	CrewManager.apply_damage(player_gunnery)
	
func choose_position(position):
	print("Helmsmenship: ", position)
