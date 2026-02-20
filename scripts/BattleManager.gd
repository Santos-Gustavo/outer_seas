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


var turn_modifiers := {
	"pos": "Parallel",
	"agg": 30,
	"fire": 10,
	"range": 10,
	"aim": "Hull"
}


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


func choose_position(pos):
	turn_modifiers["pos"] = pos

func choose_fire_policy(fire):
	#turn_modifiers["fire"] = fire
	pass

func choose_range(rang):
	#turn_modifiers["range"] = rang
	pass

func choose_aggressivity(agg):
	#turn_modifiers["agg"] = agg
	pass

func choose_aim_policy(aim):
	turn_modifiers["aim"] = aim
	
func check_hit():
	var rng = RandomNumberGenerator.new()
	var def_value = rng.randf_range(1.0, 100.0)
	
	var atk_value = float(turn_modifiers["agg"] + turn_modifiers["fire"] + turn_modifiers["range"])
	
	if atk_value > def_value:
		return 1


func resolve_round():
	var choice = turn_modifiers["aim"]
	if check_hit():
		print("Acertou Mizeravi")
		CrewManager.apply_damage(player_gunnery, choice)
	else:
		print("The princess is in another castle")
