class_name TopDownPlayer
extends CharacterBody2D

signal interaction_target_changed(target: Interactable)
signal interaction_requested(target: Interactable)

@export var speed: float = 230.0

@onready var interaction_detector: Area2D = $InteractionDetector
@onready var look_direction: Node2D = $LookDirection

var movement_enabled: bool = true
var current_target: Interactable


func _physics_process(_delta: float) -> void:
	if movement_enabled:
		var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = input_direction * speed
		if input_direction != Vector2.ZERO:
			look_direction.rotation = input_direction.angle() + PI / 2.0
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	_refresh_interaction_target()


func _unhandled_input(event: InputEvent) -> void:
	if not movement_enabled:
		return

	if event.is_action_pressed("interact") and current_target != null:
		interaction_requested.emit(current_target)
		get_viewport().set_input_as_handled()


func _refresh_interaction_target() -> void:
	var nearest_target: Interactable
	var nearest_distance := INF

	for area in interaction_detector.get_overlapping_areas():
		if area is not Interactable:
			continue

		var candidate := area as Interactable
		var distance := global_position.distance_squared_to(candidate.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_target = candidate

	if nearest_target == current_target:
		return

	current_target = nearest_target
	interaction_target_changed.emit(current_target)
