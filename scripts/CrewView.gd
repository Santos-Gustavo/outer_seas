
extends Control

var crew := [
	{"name": "Nami – Navigator", "desc": "Trusts the charts and the Government. For now."},
	{"name": "Rook – Boatswain", "desc": "Old sailor, grumbles about 'things not adding up'."},
	{"name": "Isha – Comms", "desc": "Handles the Den Den Mushi and listens more than she speaks."}
]

@onready var crew_list: ItemList = %CrewList
@onready var lbl_name: Label = %CrewName
@onready var lbl_desc: RichTextLabel = %CrewDesc

func _ready() -> void:
	for member in crew:
		crew_list.add_item(member["name"])
	crew_list.item_selected.connect(_on_crew_selected)
	if crew.size() > 0:
		crew_list.select(0)
		_on_crew_selected(0)

func _on_crew_selected(index: int) -> void:
	var member = crew[index]
	lbl_name.text = member["name"]
	lbl_desc.text = member["desc"]
