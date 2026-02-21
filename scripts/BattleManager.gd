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


var fire_hit_mod = 1
var fire_ammo_cost = 1
var fire_dmg_mod = 1
var range_hit_mod = 1
var range_dmg_mod = 1
var agg_pos_mod = 1
var agg_hit_mod = 1
var agg_def_mod = 1
var agg_dmg_mod = 1
var aim_hit_mod = 1
var aim_dmg_multiplier = 1



var round_modifiers := {
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

func _check_hit():
	var rng = RandomNumberGenerator.new()
	var def_value = rng.randf_range(1.0, 50.0)

	var atk_value = float(player_helmsmanship + player_gunnery + player_sail_handling + fire_hit_mod + range_hit_mod + agg_hit_mod - aim_hit_mod)
	print("%s % hit chance: ", atk_value)
	if atk_value > def_value:
		return 1

func _check_damage():
	var atk_value = (fire_dmg_mod + range_dmg_mod + agg_dmg_mod) * aim_dmg_multiplier
	print(atk_value)

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
