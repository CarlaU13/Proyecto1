class_name ExitDoor
extends Interactable

var is_unlocked: bool = false

@onready var door_panel: Polygon2D = $DoorPanel
@onready var indicator: Polygon2D = $Indicator


func unlock() -> void:
	if is_unlocked:
		return

	is_unlocked = true
	prompt = "Entrar a la biblioteca"
	speaker = "Narrador"
	dialogue_lines = PackedStringArray([
		"La cerradura cede con un clic. La casa finge que esto estaba previsto.",
		"Del otro lado hay una biblioteca. Al parecer, los libros también pueden ser testigos.",
	])
	door_panel.color = Color(0.25, 0.42, 0.32, 1.0)
	indicator.color = Color(0.48, 0.9, 0.58, 1.0)
