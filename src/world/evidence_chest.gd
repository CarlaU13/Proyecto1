class_name EvidenceChest
extends Interactable

var is_open: bool = false

@onready var lid: Polygon2D = $Lid
@onready var body: Polygon2D = $Body
@onready var lock_plate: Polygon2D = $LockPlate


func unlock() -> void:
	if is_open:
		return

	is_open = true
	prompt = "Revisar las evidencias"
	lid.position.y = -25.0
	lid.rotation = -0.12
	body.color = Color(0.38, 0.27, 0.18, 1.0)
	lock_plate.color = Color(0.36, 0.7, 0.42, 1.0)
