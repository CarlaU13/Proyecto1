class_name ChestLock
extends ColorRect

signal closed
signal unlocked
signal interrogation_requested

@onready var code_section: VBoxContainer = $Center/Panel/Margin/Content/CodeSection
@onready var prompt_label: Label = $Center/Panel/Margin/Content/CodeSection/Prompt
@onready var code_input: LineEdit = $Center/Panel/Margin/Content/CodeSection/CodeInput
@onready var status_label: Label = $Center/Panel/Margin/Content/CodeSection/Status
@onready var unlock_button: Button = $Center/Panel/Margin/Content/CodeSection/Actions/Unlock
@onready var hint_button: Button = $Center/Panel/Margin/Content/CodeSection/Actions/Hint
@onready var evidence_section: VBoxContainer = $Center/Panel/Margin/Content/EvidenceSection
@onready var interrogation_button: Button = $Center/Panel/Margin/Content/EvidenceSection/StartInterrogation
@onready var close_button: Button = $Center/Panel/Margin/Content/Close

var password: String = ""
var attempt_count: int = 0
var is_unlocked: bool = false


func _ready() -> void:
	unlock_button.pressed.connect(_submit_code)
	hint_button.pressed.connect(_show_hint)
	code_input.text_submitted.connect(_on_code_submitted)
	interrogation_button.pressed.connect(_request_interrogation)
	close_button.pressed.connect(close)
	hide()


func open() -> void:
	show()
	if is_unlocked:
		_show_evidence()
	else:
		code_section.show()
		evidence_section.hide()
		prompt_label.text = "La cerradura requiere una palabra de %d letras." % password.length()
		status_label.text = "La cerradura acepta una palabra. También acepta errores, para poder juzgarlos."
		code_input.grab_focus()


func close() -> void:
	hide()
	closed.emit()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _on_code_submitted(_submitted_text: String) -> void:
	_submit_code()


func _submit_code() -> void:
	var normalized_code := code_input.text.strip_edges().to_upper()
	if normalized_code == password.to_upper():
		is_unlocked = true
		unlocked.emit()
		_show_evidence()
		return

	attempt_count += 1
	status_label.text = _failure_message()
	code_input.select_all()
	code_input.grab_focus()


func _show_hint() -> void:
	status_label.text = "Pista: la clave es la palabra que el bibliotecario intentó ocultar en el pizarrón."
	code_input.grab_focus()


func _show_evidence() -> void:
	code_section.hide()
	evidence_section.show()
	close_button.grab_focus()


func _request_interrogation() -> void:
	hide()
	interrogation_requested.emit()


func mark_interrogation_solved() -> void:
	interrogation_button.text = "Revisar interrogatorio resuelto"


func _failure_message() -> String:
	match attempt_count:
		1:
			return "La cerradura no reconoce esa palabra. Al menos fue un primer intento con confianza."
		2:
			return "Incorrecto otra vez. El cofre carece de tacto, pero no de memoria."
		_:
			return "Sigue cerrado. Podés reintentar o pedir la pista sin consecuencias dramáticas."
