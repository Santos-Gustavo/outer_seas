extends Control
class_name CrewView


const SHIP_PARTS := ["Haul", "Mast", "Rudder", "Crow's Nest", "Gunport", "Bow Chaser"]
const CREW_STATUS := ["Helmsmanship", "Sail Handling", "Gunnery", "Reload", "Damage Control", "Recon"]

var crew := [
	{"ID": "Boat", "name": "Going Merry – Boat", "desc": "The boat.", "Haul": 100, "Mast": 100, "Rudder": 100, "Crow's Nest": 100, "Gunport": 100, "Bow Chaser": 100},
	{"ID": "Crew", "name": "Nami – Navigator", "desc": "Trusts the charts and the Government. For now.", "Helmsmanship": 10, "Sail Handling": 10, "Gunnery": 10, "Reload": 10, "Damage Control": 10, "Recon": 10},
	{"ID": "Crew", "name": "Rook – Boatswain", "desc": "Old sailor, grumbles about 'things not adding up'.", "Helmsmanship": 10, "Sail Handling": 10, "Gunnery": 10, "Reload": 10, "Damage Control": 10, "Recon": 10},
	{"ID": "Crew", "name": "Isha – Comms", "desc": "Handles the Den Den Mushi and listens more than she speaks.", "Helmsmanship": 10, "Sail Handling": 10, "Gunnery": 10, "Reload": 10, "Damage Control": 10, "Recon": 10}
]

@onready var crew_list: ItemList = %CrewList
@onready var lbl_name: Label = %CrewName
@onready var lbl_desc: Label = %CrewDesc
@onready var lbl_status: Label = %CrewStatus
@onready var crew_hp_now: ProgressBar = %CrewHP

func _ready() -> void:
	
	for member in crew:
		crew_list.add_item(member["name"])
	crew_list.item_selected.connect(_on_crew_selected)
	
	if crew.size() > 0:
		crew_list.select(0)
		_on_crew_selected(0)
	
	CrewManager.crew_hp.connect(_on_crew_connect)
	CrewManager.request_crew_hp()


func _on_crew_connect(maxv, minv, currentv):
	crew_hp_now.max_value = maxv
	crew_hp_now.min_value = minv
	crew_hp_now.value = currentv


func _on_crew_selected(index: int) -> void:
	var member = crew[index]
	lbl_name.text = member["name"]
	lbl_desc.text = member["desc"]
	var lines: Array[String] = []
	
	if member["ID"] == "Boat":
		for part in SHIP_PARTS:
			lines.append("%s: %s" % [part, str(member[part])])
		lbl_status.text = "\n".join(lines)
	else:
		for part in CREW_STATUS:
			lines.append("%s: %s" % [part, str(member[part])])
		lbl_status.text = "\n".join(lines)
