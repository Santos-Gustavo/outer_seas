extends Control

const CREW_STATUS := ["Helmsmanship", "Sail Handling", "Gunnery", "Reload", "Damage Control", "Recon"]
const SHIP_PARTS := ["Hull", "Mast", "Rudder", "Crow's Nest", "Gunport", "Bow Chaser"]

@onready var crew_list: ItemList = %CrewList
@onready var lbl_name: Label = %CrewName
@onready var lbl_desc: Label = %CrewDesc
@onready var lbl_status: Label = %CrewStatus
@onready var crew_hp_now: ProgressBar = %CrewHP

var active_crew: Dictionary = {}
var members: Array = [] 

func _ready() -> void:
	CrewManager.active_crew_changed.connect(_on_active_crew_changed)
	CrewManager.crew_hp_changed.connect(_on_crew_hp_changed)

	crew_list.item_selected.connect(_on_crew_selected)

	# If CrewManager already has an active crew, render immediately
	# (safe if not loaded yet — it'll just show empty until signal arrives)
	_on_active_crew_changed(CrewManager.active_crew)

func _on_active_crew_changed(crew_entry: Dictionary) -> void:
	active_crew = crew_entry
	members = active_crew.get("members", [])

	_populate_member_list()

	if members.size() > 0:
		crew_list.select(0)
		_show_member(0)
	else:
		_clear_member_details()

	# Update ship HP & stats based on current active crew
	# (CrewManager will also emit on set_active_crew, but this is harmless)
	_on_crew_hp_changed(100.0, 0.0, CrewManager.get_boat_integrity())

func _populate_member_list() -> void:
	crew_list.clear()
	for member in members:
		crew_list.add_item(str(member.get("name", "Unnamed")))

func _on_crew_hp_changed(maxv: float, minv: float, currentv: float) -> void:
	crew_hp_now.min_value = minv
	crew_hp_now.max_value = maxv
	crew_hp_now.value = currentv


func _on_crew_selected(index: int) -> void:
	_show_member(index)

func _show_member(index: int) -> void:
	if index < 0 or index >= members.size():
		_clear_member_details()
		return

	var member: Dictionary = members[index]
	lbl_name.text = str(member.get("name", "Unnamed"))
	lbl_desc.text = str(member.get("desc", ""))

	var stats: Dictionary = member.get("stats", {})
	var lines: Array[String] = []
	for key in CREW_STATUS:
		lines.append("%s: %s" % [key, str(stats.get(key, "—"))])

	lbl_status.text = "\n".join(lines)

func _clear_member_details() -> void:
	lbl_name.text = ""
	lbl_desc.text = ""
	lbl_status.text = ""
