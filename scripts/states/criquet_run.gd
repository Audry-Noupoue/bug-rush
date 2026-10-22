
class_name CriquetRun
extends BaseState

@export var criquet: CharacterBody2D


func enter() -> void:
    criquet.jouer_animation("run")


func _input(event: InputEvent) -> void:
    handle_inputs(event)


func handle_inputs(_event: InputEvent) -> void:
    pass


func update(_delta: float) -> void:
    pass


func physics_update(_delta: float) -> void:
    var direction = Input.get_axis("move_left", "move_right")

    if Input.is_action_just_pressed("dash"):
        Transitioned.emit(self, "Dash")
        return

    if Input.is_action_just_pressed("jump") and criquet.is_on_floor():
        criquet.velocity.y = criquet.JUMP_VELOCITY
        Transitioned.emit(self, "Jump")
        return

    if not criquet.is_on_floor():
        Transitioned.emit(self, "Jump")
        return

    criquet.velocity.x = direction * criquet.SPEED

    if direction > 0:
        criquet.animated_sprite.flip_h = false
    elif direction < 0:
        criquet.animated_sprite.flip_h = true

    if direction == 0:
        Transitioned.emit(self, "Idle")


func exit() -> void:
    pass
