class_name Interactable
extends Area2D

@export var interaction_id: StringName
@export var clue_id: StringName
@export var prompt: String = "Inspeccionar"
@export var speaker: String = "Narrador"
@export_multiline var dialogue_lines: PackedStringArray = []
