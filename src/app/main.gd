extends Node2D

@onready var player: TopDownPlayer = $Player
@onready var prompt: PanelContainer = $Interface/Prompt
@onready var prompt_label: Label = $Interface/Prompt/Label
@onready var dialogue_box: DialogueBox = $Interface/DialogueBox
@onready var crossword: NewspaperCrossword = $Interface/NewspaperCrossword
@onready var exit_door: ExitDoor = $Room/ExitDoor

var current_interactable: Interactable
var discovered_clues: Dictionary = {}
var show_success_dialogue_on_close: bool = false


func _ready() -> void:
	player.interaction_target_changed.connect(_on_interaction_target_changed)
	player.interaction_requested.connect(_on_interaction_requested)
	dialogue_box.closed.connect(_on_dialogue_closed)
	crossword.closed.connect(_on_crossword_closed)
	crossword.solved.connect(_on_crossword_solved)
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
	if target.interaction_id == &"newspaper":
		_open_crossword()
		return

	if not target.clue_id.is_empty():
		discovered_clues[target.clue_id] = true
	_open_dialogue(target.speaker, target.dialogue_lines)


func _open_crossword() -> void:
	player.movement_enabled = false
	prompt.hide()
	crossword.open(discovered_clues)


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


func _update_prompt() -> void:
	if current_interactable == null or dialogue_box.visible or crossword.visible:
		prompt.hide()
		return

	prompt_label.text = "[E] %s" % current_interactable.prompt
	prompt.show()
