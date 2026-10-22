
class_name CriquetIdle
extends BaseState

@export var criquet: CharacterBody2D


func enter() -> void:
	criquet.velocity.x = 0
	criquet.jouer_animation("idle")


func _input(event: InputEvent) -> void:
	handle_inputs(event)


func handle_inputs(_event: InputEvent) -> void:
	# Les touches sont verifiees dans physics_update
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")

	if Input.is_action_just_pressed("dash"):
		Transitioned.emit(self, "Dash")
		return

	if not criquet.is_on_floor():
		Transitioned.emit(self, "Jump")
		return

	if Input.is_action_just_pressed("jump"):
		criquet.velocity.y = criquet.JUMP_VELOCITY
		Transitioned.emit(self, "Jump")
		return

	if direction != 0:
		Transitioned.emit(self, "Run")


func exit() -> void:
	pass
