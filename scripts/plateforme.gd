
extends AnimatableBody2D

@export var vitesse: float = 100.0
@export var distance: float = 100.0

var mobile: bool = false
var position_depart: Vector2
var direction: int = 1


func _ready():
    position_depart = position


func _physics_process(delta):
    if not mobile:
        return

    position.x += vitesse * direction * delta

    if position.x >= position_depart.x + distance:
        direction = -1

    elif position.x <= position_depart.x - distance:
        direction = 1
