extends Node2D

const FOYER_BOUNDS := Rect2i(0, 0, 1280, 720)
const LIBRARY_BOUNDS := Rect2i(0, 900, 1280, 720)

@onready var player: TopDownPlayer = $Player
@onready var prompt: PanelContainer = $Interface/Prompt
@onready var prompt_label: Label = $Interface/Prompt/Label
@onready var dialogue_box: DialogueBox = $Interface/DialogueBox
@onready var crossword: NewspaperCrossword = $Interface/NewspaperCrossword
@onready var hangman: HangmanGame = $Interface/HangmanGame
@onready var exit_door: ExitDoor = $Room/ExitDoor
@onready var foyer_return_spawn: Marker2D = $Room/LibraryReturnSpawn
@onready var library_entry_spawn: Marker2D = $Library/EntrySpawn
@onready var librarian: Interactable = $Library/Librarian
@onready var word_board: Interactable = $Library/WordBoard
@onready var word_board_surface: Polygon2D = $Library/WordBoard/Board
@onready var word_board_text: Label = $Library/WordBoard/Blanks

var current_interactable: Interactable
var discovered_clues: Dictionary = {}
var show_success_dialogue_on_close: bool = false
var show_hangman_success_on_close: bool = false
var has_entered_library: bool = false


func _ready() -> void:
	player.interaction_target_changed.connect(_on_interaction_target_changed)
	player.interaction_requested.connect(_on_interaction_requested)
	dialogue_box.closed.connect(_on_dialogue_closed)
	crossword.closed.connect(_on_crossword_closed)
	crossword.solved.connect(_on_crossword_solved)
	hangman.closed.connect(_on_hangman_closed)
	hangman.solved.connect(_on_hangman_solved)
	call_deferred("_show_introduction")


func _show_introduction() -> void:
	_open_dialogue(
		"Narrador",
		PackedStringArray([
			"Entraste a una casa perfectamente normal.",
			"Las puertas cerradas, los muebles parlantes y la geometría dudosa no guardan relación entre sí.",
			"Movete con WASD. Presioná E cerca de algo sospechoso. En esta casa, eso significa casi todo.",
		])
	)


func _on_interaction_target_changed(target: Interactable) -> void:
	current_interactable = target
	_update_prompt()


func _on_interaction_requested(target: Interactable) -> void:
	match target.interaction_id:
		&"newspaper":
			_open_crossword()
			return
		&"library_entry":
			if exit_door.is_unlocked:
				_enter_library()
			else:
				_open_dialogue(target.speaker, target.dialogue_lines)
			return
		&"foyer_return":
			_return_to_foyer()
			return
		&"hangman":
			_open_hangman()
			return

	if not target.clue_id.is_empty():
		discovered_clues[target.clue_id] = true
	_open_dialogue(target.speaker, target.dialogue_lines)


func _enter_library() -> void:
	_prepare_room_change()
	player.place_in_room(library_entry_spawn.global_position, LIBRARY_BOUNDS)
	if has_entered_library:
		player.movement_enabled = true
		return

	has_entered_library = true
	_open_dialogue(
		"Narrador",
		PackedStringArray([
			"La biblioteca huele a papel viejo, tiza y una cantidad poco reglamentaria de sospecha.",
			"Al fondo, un bibliotecario espera frente a un pizarrón. No parece sorprendido de verte. Eso es bastante sospechoso.",
		])
	)


func _return_to_foyer() -> void:
	_prepare_room_change()
	player.place_in_room(foyer_return_spawn.global_position, FOYER_BOUNDS)
	player.movement_enabled = true


func _prepare_room_change() -> void:
	player.movement_enabled = false
	current_interactable = null
	prompt.hide()


func _open_crossword() -> void:
	player.movement_enabled = false
	prompt.hide()
	crossword.open(discovered_clues)


func _open_hangman() -> void:
	player.movement_enabled = false
	prompt.hide()
	hangman.open()


func _open_dialogue(speaker: String, lines: PackedStringArray) -> void:
	player.movement_enabled = false
	prompt.hide()
	dialogue_box.show_dialogue(speaker, lines)


func _on_dialogue_closed() -> void:
	player.movement_enabled = true
	_update_prompt()


func _on_crossword_solved() -> void:
	exit_door.unlock()
	show_success_dialogue_on_close = true


func _on_crossword_closed() -> void:
	if show_success_dialogue_on_close:
		show_success_dialogue_on_close = false
		_open_dialogue(
			"Narrador",
			PackedStringArray([
				"Tres palabras correctas. La puerta del norte acaba de destrabarse.",
				"La Gaceta Imposible lo atribuirá a su excelente periodismo, por supuesto.",
			])
		)
		return

	player.movement_enabled = true
	_update_prompt()


func _on_hangman_solved() -> void:
	show_hangman_success_on_close = true
	word_board.interaction_id = &"word_board_solved"
	word_board.prompt = "Revisar la palabra resuelta"
	word_board.dialogue_lines = PackedStringArray([
		"LLAVE. La palabra permanece escrita en el pizarrón.",
		"No apareció una llave real. La metáfora está encantada consigo misma.",
	])
	word_board_surface.color = Color(0.16, 0.31, 0.23, 1.0)
	word_board_text.text = "L  L  A  V  E"
	librarian.dialogue_lines = PackedStringArray([
		"Ganaste. La palabra era LLAVE.",
		"No voy a darte una llave real. Esto es una biblioteca, no una ferretería.",
		"Sin embargo, ya demostraste que sabés insistir. Puede que eso sirva para la próxima pista.",
	])


func _on_hangman_closed() -> void:
	if show_hangman_success_on_close:
		show_hangman_success_on_close = false
		_open_dialogue(
			"Bibliotecario",
			PackedStringArray([
				"LLAVE. Correcto.",
				"La casa reconoce tu victoria. Yo la considero estadísticamente tolerable.",
			])
		)
		return

	player.movement_enabled = true
	_update_prompt()


func _update_prompt() -> void:
	if current_interactable == null or dialogue_box.visible or crossword.visible or hangman.visible:
		prompt.hide()
		return

	prompt_label.text = "[E] %s" % current_interactable.prompt
	prompt.show()
