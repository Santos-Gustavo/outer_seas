extends Control

signal battle_started(battle_id: String)
signal battle_finished(event_id: String)
signal current_battle_changed(battle: Dictionary)


func _ready() -> void:
	current_battle_changed.emit({"test3": "test4"})


func start_battle():
	print("Starting battle")
	NavManager.set_time_scale(0.0)
	battle_started.emit("battle")
	current_battle_changed.emit(battle_started)


func current_battle() -> String:
	return "Aloha"


func attack(damage):
	CrewManager.apply_damage(damage)
