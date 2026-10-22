
class_name CriquetDash
extends BaseState

@export var criquet: CharacterBody2D

var temps_dash: float = 0.0
var direction_dash: float = 1.0


func enter() -> void:
    temps_dash = criquet.DASH_DURATION

    direction_dash = -1.0 if criquet.animated_sprite.flip_h else 1.0

    var direction = Input.get_axis("move_left", "move_right")

    if direction != 0:
        direction_dash = direction

    criquet.jouer_animation("dash")


func _input(event: InputEvent) -> void:
    handle_inputs(event)


func handle_inputs(_event: InputEvent) -> void:
    pass


func update(_delta: float) -> void:
    pass


func physics_update(delta: float) -> void:
    temps_dash -= delta

    criquet.velocity.x = direction_dash * criquet.DASH_SPEED

    if temps_dash <= 0:
        if not criquet.is_on_floor():
            Transitioned.emit(self, "Jump")
        elif Input.get_axis("move_left", "move_right") != 0:
            Transitioned.emit(self, "Run")
        else:
            Transitioned.emit(self, "Idle")


func exit() -> void:
    pass
