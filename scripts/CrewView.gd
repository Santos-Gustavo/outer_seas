extends Control
class_name CrewView

var crew := [
	{"name": "Going Merry – Boat", "desc": "The boat."},
	{"name": "Nami – Navigator", "desc": "Trusts the charts and the Government. For now."},
	{"name": "Rook – Boatswain", "desc": "Old sailor, grumbles about 'things not adding up'."},
	{"name": "Isha – Comms", "desc": "Handles the Den Den Mushi and listens more than she speaks."}
]

@onready var crew_list: ItemList = %CrewList
@onready var lbl_name: Label = %CrewName
@onready var lbl_desc: RichTextLabel = %CrewDesc
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
