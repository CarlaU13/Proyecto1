class_name ImpostorGame
extends ColorRect

signal closed
signal solved

const SECRET_WORD: String = "AJEDREZ"
const IMPOSTOR_HINT: String = "JUEGO DE MESA"
const IMPOSTOR_ID: StringName = &"late_guest"
const PARTICIPANTS: Array[Dictionary] = [
	{
		"id": &"detective",
		"name": "La Detective",
		"statement": "ENROQUE",
	},
	{
		"id": &"librarian",
		"name": "El Bibliotecario",
		"statement": "ALFIL",
	},
	{
		"id": &"illusionist",
		"name": "La Ilusionista",
		"statement": "GAMBITO",
	},
	{
		"id": &"witness",
		"name": "La Testigo",
		"statement": "JAQUE",
	},
	{
		"id": IMPOSTOR_ID,
		"name": "El Invitado Tardío",
		"statement": "TABLERO",
	},
]
const HINTS: PackedStringArray = [
	"Buscá la declaración menos específica. La persona sin la palabra recibió una categoría más amplia.",
	"Cuatro términos pertenecen casi exclusivamente al ajedrez; uno también sirve para muchos otros juegos.",
	"El impostor recibió la pista «JUEGO DE MESA». Ahora su elección debería resultar bastante menos misteriosa.",
]

@onready var secret_label: Label = $Center/Panel/Margin/Content/Secret
@onready var participants: VBoxContainer = $Center/Panel/Margin/Content/Participants
@onready var status_label: Label = $Center/Panel/Margin/Content/Status
@onready var hint_button: Button = $Center/Panel/Margin/Content/Actions/Hint
@onready var close_button: Button = $Center/Panel/Margin/Content/Actions/Close

var participant_buttons: Dictionary = {}
var rejected_participants: Dictionary = {}
var attempt_count: int = 0
var hint_index: int = 0
var is_solved: bool = false


func _ready() -> void:
	_build_participant_buttons()
	hint_button.pressed.connect(_show_next_hint)
	close_button.pressed.connect(close)
	secret_label.text = "PALABRA SECRETA: %s" % SECRET_WORD
	hide()


func open() -> void:
	show()
	if is_solved:
		_show_solution()
	else:
		status_label.text = "Elegí quién recibió solamente una pista e intentó mezclarse con el grupo."
		_focus_first_available_participant()


func close() -> void:
	hide()
	closed.emit()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _build_participant_buttons() -> void:
	for participant: Dictionary in PARTICIPANTS:
		var participant_id: StringName = participant["id"]
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 54)
		button.text = "%s  —  «%s»" % [participant["name"], participant["statement"]]
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(_select_participant.bind(participant_id))
		participants.add_child(button)
		participant_buttons[participant_id] = button


func _select_participant(participant_id: StringName) -> void:
	if is_solved or rejected_participants.has(participant_id):
		return

	if participant_id == IMPOSTOR_ID:
		is_solved = true
		solved.emit()
		_show_solution()
		return

	attempt_count += 1
	rejected_participants[participant_id] = true
	var button: Button = participant_buttons[participant_id]
	button.disabled = true
	button.text += "  ·  DESCARTADO"
	status_label.text = _failure_message()
	_focus_first_available_participant()


func _show_next_hint() -> void:
	if is_solved:
		return

	status_label.text = "Pista %d/3: %s" % [hint_index + 1, HINTS[hint_index]]
	hint_index = mini(hint_index + 1, HINTS.size() - 1)
	if hint_index == HINTS.size() - 1:
		hint_button.text = "Pista definitiva"


func _show_solution() -> void:
	for participant_id: StringName in participant_buttons:
		var button: Button = participant_buttons[participant_id]
		button.disabled = true
		if participant_id == IMPOSTOR_ID and not button.text.ends_with("IMPOSTOR"):
			button.text += "  ·  IMPOSTOR"

	status_label.text = (
		"Correcto. El Invitado Tardío recibió «%s» y eligió TABLERO: relacionado, "
		+ "pero mucho menos específico que ENROQUE, ALFIL, GAMBITO o JAQUE."
	) % IMPOSTOR_HINT
	hint_button.disabled = true
	close_button.grab_focus()


func _failure_message() -> String:
	match attempt_count:
		1:
			return "No era esa persona. Una acusación firme sigue siendo una acusación equivocada. Podés continuar."
		2:
			return "Tampoco. El narrador recomienda comparar precisión, no volumen de sospecha."
		_:
			return "Otra coartada intacta. Pedí una pista o examiná qué palabra podría surgir de una categoría más amplia."


func _focus_first_available_participant() -> void:
	for participant: Dictionary in PARTICIPANTS:
		var participant_id: StringName = participant["id"]
		var button: Button = participant_buttons[participant_id]
		if not button.disabled:
			button.grab_focus()
			return
