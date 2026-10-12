extends Node2D

@onready var player: TopDownPlayer = $Player
@onready var prompt: PanelContainer = $Interface/Prompt
@onready var prompt_label: Label = $Interface/Prompt/Label
@onready var dialogue_box: DialogueBox = $Interface/DialogueBox

var current_interactable: Interactable


func _ready() -> void:
	player.interaction_target_changed.connect(_on_interaction_target_changed)
	player.interaction_requested.connect(_on_interaction_requested)
	dialogue_box.closed.connect(_on_dialogue_closed)
	call_deferred("_show_introduction")


func _show_introduction() -> void:
	_open_dialogue(
		"Narrator",
		PackedStringArray([
			"You have entered a perfectly ordinary house.",
			"The locked doors, talking furniture, and questionable geometry are unrelated.",
			"Walk with WASD. Press E near anything suspicious. In this house, that means almost everything.",
		])
	)


func _on_interaction_target_changed(target: Interactable) -> void:
	current_interactable = target
	_update_prompt()


func _on_interaction_requested(target: Interactable) -> void:
	_open_dialogue(target.speaker, target.dialogue_lines)


func _open_dialogue(speaker: String, lines: PackedStringArray) -> void:
	player.movement_enabled = false
	prompt.hide()
	dialogue_box.show_dialogue(speaker, lines)


func _on_dialogue_closed() -> void:
	player.movement_enabled = true
	_update_prompt()


func _update_prompt() -> void:
	if current_interactable == null or dialogue_box.visible:
		prompt.hide()
		return

	prompt_label.text = "[E] %s" % current_interactable.prompt
	prompt.show()
