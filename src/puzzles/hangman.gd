class_name HangmanGame
extends ColorRect

signal closed
signal solved

const WORD: String = "LLAVE"
const ALPHABET: String = "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ"
const MAX_MISTAKES: int = 6
const HINTS: PackedStringArray = [
	"Sirve para abrir algo, aunque por sí sola no es una puerta.",
	"Tiene cinco letras, empieza con L y aparece demasiado seguido en historias con cerraduras.",
	"La palabra es LLAVE. El bibliotecario pide que finjas haberla deducido.",
]
const GALLOWS: PackedStringArray = [
	"  ┌─────┐\n  │     │\n  │\n  │\n  │\n──┴──",
	"  ┌─────┐\n  │     │\n  │     O\n  │\n  │\n──┴──",
	"  ┌─────┐\n  │     │\n  │     O\n  │     │\n  │\n──┴──",
	"  ┌─────┐\n  │     │\n  │     O\n  │    /│\n  │\n──┴──",
	"  ┌─────┐\n  │     │\n  │     O\n  │    /│\\\n  │\n──┴──",
	"  ┌─────┐\n  │     │\n  │     O\n  │    /│\\\n  │    /\n──┴──",
	"  ┌─────┐\n  │     │\n  │     O\n  │    /│\\\n  │    / \\\n──┴──",
]

@onready var gallows_label: Label = $Center/Panel/Margin/Content/GameRow/Gallows
@onready var word_label: Label = $Center/Panel/Margin/Content/GameRow/PlayArea/Word
@onready var wrong_letters_label: Label = $Center/Panel/Margin/Content/GameRow/PlayArea/WrongLetters
@onready var letters: GridContainer = $Center/Panel/Margin/Content/GameRow/PlayArea/Letters
@onready var status_label: Label = $Center/Panel/Margin/Content/Status
@onready var hint_button: Button = $Center/Panel/Margin/Content/Actions/Hint
@onready var retry_button: Button = $Center/Panel/Margin/Content/Actions/Retry
@onready var close_button: Button = $Center/Panel/Margin/Content/Actions/Close

var guessed_letters: Dictionary = {}
var wrong_letters: PackedStringArray = []
var letter_buttons: Dictionary = {}
var mistakes: int = 0
var hint_index: int = 0
var round_failed: bool = false
var is_solved: bool = false


func _ready() -> void:
	_build_letter_buttons()
	hint_button.pressed.connect(_show_next_hint)
	retry_button.pressed.connect(_retry_round)
	close_button.pressed.connect(close)
	_reset_round()
	hide()


func open() -> void:
	show()
	_update_display()
	if is_solved or round_failed:
		close_button.grab_focus()
	else:
		_focus_first_available_letter()


func close() -> void:
	hide()
	closed.emit()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
		return

	if event is not InputEventKey or not event.pressed or event.echo or is_solved or round_failed:
		return

	var key_event := event as InputEventKey
	var letter := String.chr(key_event.unicode).to_upper()
	if letter.length() == 1 and ALPHABET.contains(letter):
		_guess_letter(letter)
		get_viewport().set_input_as_handled()


func _build_letter_buttons() -> void:
	for index in ALPHABET.length():
		var letter := ALPHABET.substr(index, 1)
		var button := Button.new()
		button.custom_minimum_size = Vector2(48, 42)
		button.text = letter
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(_guess_letter.bind(letter))
		letters.add_child(button)
		letter_buttons[letter] = button


func _guess_letter(letter: String) -> void:
	if is_solved or round_failed or guessed_letters.has(letter):
		return

	guessed_letters[letter] = true
	var button: Button = letter_buttons[letter]
	button.disabled = true

	if WORD.contains(letter):
		status_label.text = "Correcto. El bibliotecario intenta no parecer impresionado."
		if _word_is_complete():
			_complete_game()
	else:
		mistakes += 1
		wrong_letters.append(letter)
		if mistakes >= MAX_MISTAKES:
			_fail_round()
		else:
			status_label.text = "Esa letra no está. El bibliotecario anotó el error con innecesaria satisfacción."

	_update_display()
	if not is_solved and not round_failed:
		_focus_first_available_letter()


func _word_is_complete() -> bool:
	for index in WORD.length():
		if not guessed_letters.has(WORD.substr(index, 1)):
			return false
	return true


func _complete_game() -> void:
	is_solved = true
	status_label.text = "LLAVE. Correcto. El pizarrón acepta tu victoria a regañadientes."
	hint_button.disabled = true
	retry_button.hide()
	_set_letter_buttons_disabled(true)
	solved.emit()


func _fail_round() -> void:
	round_failed = true
	status_label.text = "Seis errores. La palabra sobrevivió; tu prestigio está en observación. Podés reintentar."
	retry_button.show()
	_set_letter_buttons_disabled(true)
	retry_button.grab_focus()


func _retry_round() -> void:
	_reset_round()
	status_label.text = "Nueva ronda, misma palabra. Hasta el bibliotecario considera que eso es suficientemente justo."
	_focus_first_available_letter()


func _reset_round() -> void:
	guessed_letters.clear()
	wrong_letters.clear()
	mistakes = 0
	round_failed = false
	retry_button.hide()
	_set_letter_buttons_disabled(false)
	_update_display()


func _show_next_hint() -> void:
	if is_solved:
		return

	status_label.text = "Pista %d/3: %s" % [hint_index + 1, HINTS[hint_index]]
	hint_index = mini(hint_index + 1, HINTS.size() - 1)
	if hint_index == HINTS.size() - 1:
		hint_button.text = "Pista definitiva"


func _update_display() -> void:
	gallows_label.text = GALLOWS[mistakes]
	var displayed_letters: PackedStringArray = []
	for index in WORD.length():
		var letter := WORD.substr(index, 1)
		displayed_letters.append(letter if guessed_letters.has(letter) or is_solved else "_")
	word_label.text = "  ".join(displayed_letters)
	wrong_letters_label.text = "Errores %d/%d · Letras: %s" % [
		mistakes,
		MAX_MISTAKES,
		", ".join(wrong_letters) if not wrong_letters.is_empty() else "ninguna",
	]


func _set_letter_buttons_disabled(disabled: bool) -> void:
	for letter: String in letter_buttons:
		var button: Button = letter_buttons[letter]
		button.disabled = disabled or guessed_letters.has(letter)


func _focus_first_available_letter() -> void:
	for letter: String in letter_buttons:
		var button: Button = letter_buttons[letter]
		if not button.disabled:
			button.grab_focus()
			return
