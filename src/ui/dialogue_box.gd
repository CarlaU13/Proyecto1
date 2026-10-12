class_name DialogueBox
extends MarginContainer

signal closed

@onready var speaker_label: Label = $Panel/Margin/Content/Speaker
@onready var text_label: Label = $Panel/Margin/Content/Text
@onready var continue_button: Button = $Panel/Margin/Content/Continue

var lines: PackedStringArray
var line_index: int = 0


func _ready() -> void:
	continue_button.pressed.connect(_advance)
	hide()


func show_dialogue(speaker: String, dialogue_lines: PackedStringArray) -> void:
	if dialogue_lines.is_empty():
		return

	speaker_label.text = speaker
	lines = dialogue_lines.duplicate()
	line_index = 0
	show()
	_show_current_line()
	continue_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_accept"):
		_advance()
		get_viewport().set_input_as_handled()


func _advance() -> void:
	line_index += 1
	if line_index >= lines.size():
		hide()
		closed.emit()
		return

	_show_current_line()


func _show_current_line() -> void:
	text_label.text = lines[line_index]
	continue_button.text = "Continuar  [Enter]" if line_index < lines.size() - 1 else "Cerrar  [Enter]"
