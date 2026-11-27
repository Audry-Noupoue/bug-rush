
extends Node

@export var initial_state: BaseState

var current_state: BaseState
var states: Dictionary = {}


func _ready() -> void:
	for child in get_children():
		if child is BaseState:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)

func demarrer() -> void:
	if initial_state:
		current_state = initial_state
		current_state.enter()
	


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func on_child_transition(state: BaseState, new_state_name: String) -> void:
	if state != current_state:
		return

	var new_state: BaseState = states.get(new_state_name.to_lower())

	if new_state == null:
		return

	current_state.exit()
	current_state = new_state
	current_state.enter()
