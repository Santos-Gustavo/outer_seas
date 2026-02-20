extends Control


const SHIP_PARTS := ["Hull", "Mast", "Rudder", "Crow's Nest", "Gunport", "Bow Chaser"]
const CREW_STATUS := ["Helmsmanship", "Sail Handling", "Gunnery", "Reload", "Damage Control", "Recon"]


@onready var crew_list: ItemList = %CrewList
@onready var lbl_name: Label = %CrewName
@onready var lbl_desc: Label = %CrewDesc
@onready var lbl_status: Label = %CrewStatus
@onready var crew_hp_now: ProgressBar = %CrewHP


var complete_crew

func _ready() -> void:
	CrewManager.complete_crew_status.connect(_on_complete_crew_connect)
	CrewManager.request_complete_crew_status()
	
	for member in complete_crew:
		crew_list.add_item(member["name"])
	crew_list.item_selected.connect(_on_crew_selected)
	
	if complete_crew.size() > 0:
		crew_list.select(0)
		_on_crew_selected(0)
	
	CrewManager.crew_hp.connect(_on_crew_connect)
	CrewManager.request_crew_hp()
	
	


func _on_complete_crew_connect(crew):
	complete_crew = crew

func _on_crew_connect(maxv, minv, currentv):
	crew_hp_now.max_value = maxv
	crew_hp_now.min_value = minv
	crew_hp_now.value = currentv


func _on_crew_selected(index: int) -> void:
	var member = complete_crew[index]
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
