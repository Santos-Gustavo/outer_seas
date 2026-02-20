extends Control
#class_name Battle_Manager

signal current_battle_change(battle: Dictionary)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_battle_change.emit({"test3": "test4"})


func start_battle():
	NavManager.set_time_scale(0.0)
	current_battle_change.emit({"test": "test1"})



func current_battle() -> String:
	return "Aloha"


func attack(damage):
	CrewManager.apply_damage(damage)
