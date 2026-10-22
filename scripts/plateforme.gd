
extends AnimatableBody2D

@export var vitesse: float = 50.0

var mobile: bool = false
var direction_mouvement: Vector2 = Vector2.ZERO
var distance: float = 100.0


func _ready():
    if mobile:
        demarrer_mouvement()


func demarrer_mouvement():
    var destination = position + direction_mouvement * distance

    var duree = distance / vitesse

    var tween = create_tween()
    tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
    tween.set_loops()

    tween.tween_property(
        self,
        "position",
        destination,
        duree
    )

    tween.tween_property(
        self,
        "position",
        position,
        duree
    )
