class_name NewspaperCrossword
extends ColorRect

signal closed
signal solved

const GRID_SIZE: int = 6
const WORDS: Dictionary = {
	"cup": {
		"answer": "TAZA",
		"start": Vector2i(1, 1),
		"direction": Vector2i.RIGHT,
	},
	"clock": {
		"answer": "TRECE",
		"start": Vector2i(1, 2),
		"direction": Vector2i.RIGHT,
	},
	"portrait": {
		"answer": "MARCO",
		"start": Vector2i(2, 0),
		"direction": Vector2i.DOWN,
	},
}
const CLUE_TEXTS: Dictionary = {
	"cup": "1. Horizontal: Tiene asa, pero no es valija. Está sobre la mesa.",
	"clock": "2. Horizontal: Cantidad imposible de marcas del reloj.",
	"portrait": "3. Vertical: Rodea el retrato y mejora cualquier pregunta, según él.",
}
const HINTS: PackedStringArray = [
	"El reloj cuenta mejor que vos, aunque llegó hasta un número sospechoso.",
	"La taza y el marco no decoran: están esperando que alguien los nombre.",
	"Bien, detective. Las respuestas son TAZA, TRECE y MARCO. Intentá parecer sorprendido.",
]

@onready var grid: GridContainer = $Center/Panel/Margin/Content/PuzzleRow/Grid
@onready var clues: VBoxContainer = $Center/Panel/Margin/Content/PuzzleRow/Clues
@onready var status_label: Label = $Center/Panel/Margin/Content/Status
@onready var hint_button: Button = $Center/Panel/Margin/Content/Actions/Hint
@onready var check_button: Button = $Center/Panel/Margin/Content/Actions/Check
@onready var close_button: Button = $Center/Panel/Margin/Content/Actions/Close

var expected_cells: Dictionary = {}
var cells: Dictionary = {}
var clue_labels: Dictionary = {}
var discovered_clues: Dictionary = {}
var hint_index: int = 0
var attempt_count: int = 0
var is_solved: bool = false


func _ready() -> void:
	_build_expected_cells()
	_build_grid()
	_build_clue_labels()
	hint_button.pressed.connect(_show_next_hint)
	check_button.pressed.connect(_check_solution)
	close_button.pressed.connect(close)
	hide()


func open(known_clues: Dictionary) -> void:
	discovered_clues = known_clues.duplicate()
	_update_clues()
	if is_solved:
		status_label.text = "Crucigrama resuelto. La puerta sigue abierta y el diario sigue adjudicándose el mérito."
		status_label.modulate = Color(0.18, 0.42, 0.22, 1.0)
	else:
		status_label.text = "El papel acepta lápiz, teclado y decisiones discutibles."
		status_label.modulate = Color(0.35, 0.22, 0.12, 1.0)
	show()
	if not is_solved:
		_focus_first_empty_cell()
	else:
		close_button.grab_focus()


func close() -> void:
	hide()
	closed.emit()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("hint"):
		_show_next_hint()
		get_viewport().set_input_as_handled()


func _build_expected_cells() -> void:
	for word_data: Dictionary in WORDS.values():
		var answer: String = word_data["answer"]
		var start: Vector2i = word_data["start"]
		var direction: Vector2i = word_data["direction"]
		for index in answer.length():
			expected_cells[start + direction * index] = answer[index]


func _build_grid() -> void:
	for row in GRID_SIZE:
		for column in GRID_SIZE:
			var position := Vector2i(column, row)
			if expected_cells.has(position):
				var cell := LineEdit.new()
				cell.custom_minimum_size = Vector2(48, 48)
				cell.max_length = 1
				cell.alignment = HORIZONTAL_ALIGNMENT_CENTER
				cell.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_DEFAULT
				cell.add_theme_font_size_override("font_size", 24)
				cell.add_theme_color_override("font_color", Color(0.13, 0.11, 0.09, 1.0))
				cell.add_theme_color_override("caret_color", Color(0.35, 0.22, 0.12, 1.0))
				cell.add_theme_stylebox_override("normal", _cell_style(Color(0.93, 0.87, 0.7, 1.0)))
				cell.add_theme_stylebox_override("focus", _cell_style(Color(1.0, 0.94, 0.73, 1.0), 3))
				cell.text_changed.connect(_on_cell_text_changed.bind(cell))
				grid.add_child(cell)
				cells[position] = cell
			else:
				var blank := ColorRect.new()
				blank.custom_minimum_size = Vector2(48, 48)
				blank.color = Color(0.12, 0.105, 0.09, 1.0)
				grid.add_child(blank)


func _build_clue_labels() -> void:
	for clue_id: String in ["cup", "clock", "portrait"]:
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size.x = 340.0
		label.add_theme_font_size_override("font_size", 17)
		clues.add_child(label)
		clue_labels[clue_id] = label


func _update_clues() -> void:
	for clue_id: String in clue_labels:
		var label: Label = clue_labels[clue_id]
		if discovered_clues.has(clue_id):
			label.text = CLUE_TEXTS[clue_id]
			label.modulate = Color(0.17, 0.13, 0.09, 1.0)
		else:
			label.text = "%s. Todavía falta inspeccionar algo en la habitación." % _clue_number(clue_id)
			label.modulate = Color(0.42, 0.36, 0.29, 1.0)


func _on_cell_text_changed(new_text: String, cell: LineEdit) -> void:
	var normalized := new_text.to_upper()
	if normalized.length() > 1:
		normalized = normalized.right(1)
	if cell.text != normalized:
		cell.text = normalized
		cell.caret_column = normalized.length()
	if not normalized.is_empty():
		call_deferred("_focus_next_empty_cell", cell)


func _check_solution() -> void:
	if is_solved:
		return

	for position: Vector2i in expected_cells:
		var cell: LineEdit = cells[position]
		if cell.text.to_upper() != expected_cells[position]:
			attempt_count += 1
			status_label.text = _failure_message()
			cell.grab_focus()
			return

	is_solved = true
	status_label.text = "Correcto. La cerradura acaba de perder una discusión con el periodismo."
	status_label.modulate = Color(0.18, 0.42, 0.22, 1.0)
	for cell: LineEdit in cells.values():
		cell.editable = false
	hint_button.disabled = true
	check_button.disabled = true
	close_button.grab_focus()
	solved.emit()


func _show_next_hint() -> void:
	if is_solved:
		return

	status_label.modulate = Color(0.35, 0.22, 0.12, 1.0)
	status_label.text = "Pista %d/3: %s" % [hint_index + 1, HINTS[hint_index]]
	hint_index = mini(hint_index + 1, HINTS.size() - 1)


func _failure_message() -> String:
	match attempt_count:
		1:
			return "No. Pero fue una forma elegante de equivocarse. Podés reintentar."
		2:
			return "El crucigrama sigue intacto. Tu reputación, un poco menos."
		_:
			return "La tinta no va a rendirse por cansancio. Probá otra vez o pedí una pista."


func _focus_first_empty_cell() -> void:
	for position: Vector2i in expected_cells:
		var cell: LineEdit = cells[position]
		if cell.text.is_empty():
			cell.grab_focus()
			return


func _focus_next_empty_cell(current_cell: LineEdit) -> void:
	var ordered_cells: Array[LineEdit] = []
	for child in grid.get_children():
		if child is LineEdit:
			ordered_cells.append(child as LineEdit)

	var current_index := ordered_cells.find(current_cell)
	for offset in range(1, ordered_cells.size() + 1):
		var candidate := ordered_cells[(current_index + offset) % ordered_cells.size()]
		if candidate.text.is_empty():
			candidate.grab_focus()
			return
	check_button.grab_focus()


func _cell_style(color: Color, border_width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.border_color = Color(0.3, 0.2, 0.12, 1.0)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	return style


func _clue_number(clue_id: String) -> int:
	match clue_id:
		"cup":
			return 1
		"clock":
			return 2
		_:
			return 3
