
class_name CriquetJump
extends BaseState

@export var criquet: CharacterBody2D


func enter() -> void:
    criquet.jouer_animation("jump")


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

    criquet.velocity.x = direction * criquet.SPEED

    if direction > 0:
        criquet.animated_sprite.flip_h = false
    elif direction < 0:
        criquet.animated_sprite.flip_h = true

    if criquet.is_on_floor():
        if direction != 0:
            Transitioned.emit(self, "Run")
        else:
            Transitioned.emit(self, "Idle")


func exit() -> void:
    pass
