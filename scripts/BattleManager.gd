extends Node

signal battle_started(battle_id: String)
signal battle_finished(event_id: String)
signal current_battle_changed(battle: Dictionary)

var rng := RandomNumberGenerator.new()

# Player stats (filled from CrewManager)
var player_stats: Dictionary = {}

# Enemy stats (stub for now — you should replace later with enemy data)
var enemy_stats: Dictionary = {}

# These should come from your selection system later
var fire_hit_mod := 0.0
var range_hit_mod := 0.0
var agg_hit_mod := 0.0
var aim_hit_mod := 0.0

var fire_ammo_cost = 1 
var fire_dmg_mod = 1 
var range_dmg_mod = 1 
var agg_pos_mod = 1 
var agg_def_mod = 1 
var agg_dmg_mod = 1
var aim_dmg_multiplier = 1


var round_modifiers := {
	"pos": "Parallel",
	"agg": 0,       # recommend: index, not 30
	"fire": 0,      # recommend: index
	"range": 0,     # recommend: index
	"aim": "Hull"
}

func _ready() -> void:
	rng.randomize()

	if not CrewManager.crew_stats_changed.is_connected(_on_player_crew_stats_changed):
		CrewManager.crew_stats_changed.connect(_on_player_crew_stats_changed)

	player_stats = CrewManager.get_crew_stats_by_id("main")

	current_battle_changed.emit({"state": "idle"})

func _on_player_crew_stats_changed(stats: Dictionary) -> void:
	player_stats = stats

func start_battle(enemy_crew_id: String) -> void:
	print("Starting battle vs:", enemy_crew_id)
	NavManager.set_time_scale(0.0)

	player_stats = CrewManager.get_crew_stats_by_id("main")  # active player crew
	enemy_stats  = CrewManager.get_crew_stats_by_id(enemy_crew_id)

	# Emit once, with one coherent state payload
	battle_started.emit(enemy_crew_id)
	current_battle_changed.emit({
		"state": "active",
		"enemy_id": enemy_crew_id,
		"round_modifiers": round_modifiers
	})

func _check_hit() -> bool:
	# Defender roll (replace later with real defense system)
	print(player_stats)
	print(enemy_stats)
	var def_value := (
		float(enemy_stats.get("Helmsmanship", 0.0))
		+ float(player_stats.get("Sail Handling", 0.0))
		)

	# Attacker value (your logic, but now safe + explicit)
	var atk_value := (
		float(player_stats.get("Helmsmanship", 0.0)) 
		+ float(player_stats.get("Gunnery", 0.0))
		+ float(player_stats.get("Sail Handling", 0.0))
		+ fire_hit_mod + range_hit_mod + agg_hit_mod - aim_hit_mod
		)

	#print("Hit check: atk=", atk_value, " def=", def_value)

	return atk_value > def_value

func choose_position(pos):

	if pos == "Parallel":
		pass
	elif pos == "Rake":
		pass
	elif pos == "Chase":
		pass
	elif pos == "Head-on":
		pass
	elif pos == "Disengaging":
		pass
	else:
		push_error("%s is not correct", pos)
		return
	round_modifiers["pos"] = pos

func choose_fire_policy(fire):
	if fire == "Accurate":
		fire_hit_mod = 8.0
		fire_ammo_cost = 1
		fire_dmg_mod = 1
	elif fire == "Balanced":
		fire_hit_mod = 0.0
		fire_ammo_cost = 2
		fire_dmg_mod = 0
	elif fire == "Fire-at-will":
		fire_hit_mod = -10.0
		fire_ammo_cost = 4
		fire_dmg_mod = -1
	else:
		push_error("%s is not correct", fire)
		return

func choose_range(rang):
	if rang == "Far":
		range_hit_mod = -15.0
		range_dmg_mod = -2.0
	elif rang == "Medium":
		range_hit_mod = 0.0
		range_dmg_mod = 0.0
	elif rang == "Close":
		range_hit_mod = 15.0
		range_dmg_mod = 2.0
	else:
		push_error("%s is not correct", rang)
		return

func choose_aggressivity(agg):
	if agg == "Ultra Defensive":
		agg_pos_mod = -2.0
		agg_hit_mod = -10.0
		agg_def_mod = 10.0
		agg_dmg_mod = -2.0
	elif agg == "Defensive":
		agg_pos_mod = -1.0
		agg_hit_mod = -5.0
		agg_def_mod = 5.0
		agg_dmg_mod = -1.0
	elif agg == "Balanced":
		agg_pos_mod = 0
		agg_hit_mod = 0.0
		agg_def_mod = 0.0
		agg_dmg_mod = 0.0
	elif agg == "Aggressive":
		agg_pos_mod = 1.0
		agg_hit_mod = 5.0
		agg_def_mod = -5.0
		agg_dmg_mod = 1.0
	elif agg == "Ultra Aggressive":
		agg_pos_mod = 2.0
		agg_hit_mod = 10.0
		agg_def_mod = -10.0
		agg_dmg_mod = 2.0
	else:
		push_error("%s is not correct", agg)
		return

func choose_aim_policy(aim):
	if aim == "Hull":
		aim_hit_mod = 5
		aim_dmg_multiplier = 1.2
	elif aim == "Mast":
		aim_hit_mod = 20
		aim_dmg_multiplier = 1.2
	elif aim == "Rudder":
		aim_hit_mod = 20
		aim_dmg_multiplier = 1.5
	elif aim == "Crow's Nest":
		aim_hit_mod = 10
		aim_dmg_multiplier = 1.3
	elif aim == "Gunport":
		aim_hit_mod = 10
		aim_dmg_multiplier = 1.3
	elif aim == "Bow Chaser":
		aim_hit_mod = 10
		aim_dmg_multiplier = 1.4
	else:
		push_error("%s is not correct", aim)
		return
	round_modifiers["aim"] = aim

func _check_damage() -> float:
	var atk_value = (fire_dmg_mod + range_dmg_mod + agg_dmg_mod) * aim_dmg_multiplier

	return atk_value

func resolve_round():
	var choice = round_modifiers["aim"]
	var number_atks = fire_ammo_cost

	for i in range(number_atks):
		if _check_hit():
			print("Acertou Mizeravi")
			CrewManager.apply_damage(_check_damage(), choice)
		else:
			print("The princess is in another castle")
