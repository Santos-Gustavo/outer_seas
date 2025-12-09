
extends Control

@onready var info := $MarginContainer/VBoxContainer/ToolInfo

func _ready() -> void:
	var bar = $MarginContainer/VBoxContainer/ToolButtons
	bar.get_node("btn_compass").pressed.connect(func(): _show_compass())
	bar.get_node("btn_map").pressed.connect(func(): _show_map())
	bar.get_node("btn_spyglass").pressed.connect(func(): _show_spyglass())
	bar.get_node("btn_mushi").pressed.connect(func(): _show_mushi())
	bar.get_node("btn_logpose").pressed.connect(func(): _show_logpose())
	_show_compass()

func _show_compass() -> void:
	info.text = "Compass\n\nCurrently points north. Sometimes feels unstable near patrol zones..."

func _show_map() -> void:
	info.text = "Map\n\nShows your current sea with Capital, Ashfall and Open Sea. A great storm is marked at the center: the Shrouded Eye."

func _show_spyglass() -> void:
	info.text = "Spyglass\n\nLets you see distant ships and islands. In heavy weather, faint flashes reveal more than they should."

func _show_mushi() -> void:
	info.text = "Den Den Mushi\n\nUsed for ship-to-ship communications. There is a hidden diagnostics mode only technicians talk about."

func _show_logpose() -> void:
	info.text = "Log Pose\n\nPoints to the dominant island in a region. A faint second needle sometimes twitches for no obvious reason."
