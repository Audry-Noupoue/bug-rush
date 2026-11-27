
class_name BaseState
extends Node

signal Transitioned(state, new_state_name)

func enter() -> void:
    pass

func exit() -> void:
    pass

func handle_inputs(_event: InputEvent) -> void:
    pass

func update(_delta: float) -> void:
    pass

func physics_update(_delta: float) -> void:
    pass
