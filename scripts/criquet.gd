
extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -600.0
const DASH_SPEED = 650.0
const DASH_DURATION = 0.25

enum Etat {
    IDLE,
    RUN,
    JUMP,
    DASH
}

var etat_actuel = Etat.IDLE
var temps_dash = 0.0
var direction_dash = 1.0

@onready var animated_sprite = $AnimatedSprite2D


func _physics_process(delta):
    var direction = Input.get_axis("move_left", "move_right")

    if not is_on_floor():
        velocity += get_gravity() * delta

    if Input.is_action_just_pressed("dash") and etat_actuel != Etat.DASH:
        direction_dash = -1.0 if animated_sprite.flip_h else 1.0

        if direction != 0:
            direction_dash = direction

        temps_dash = DASH_DURATION
        changer_etat(Etat.DASH)

    match etat_actuel:
        Etat.DASH:
            temps_dash -= delta
            velocity.x = direction_dash * DASH_SPEED

            if temps_dash <= 0:
                if not is_on_floor():
                    changer_etat(Etat.JUMP)
                elif direction != 0:
                    changer_etat(Etat.RUN)
                else:
                    changer_etat(Etat.IDLE)

        _:
            if Input.is_action_just_pressed("jump") and is_on_floor():
                velocity.y = JUMP_VELOCITY

            velocity.x = direction * SPEED

            if direction > 0:
                animated_sprite.flip_h = false
            elif direction < 0:
                animated_sprite.flip_h = true

    move_and_slide()

    if etat_actuel != Etat.DASH:
        if not is_on_floor():
            changer_etat(Etat.JUMP)
        elif direction != 0:
            changer_etat(Etat.RUN)
        else:
            changer_etat(Etat.IDLE)


func changer_etat(nouvel_etat):
    if etat_actuel == nouvel_etat:
        return

    etat_actuel = nouvel_etat

    match etat_actuel:
        Etat.IDLE:
            jouer_animation("idle")

        Etat.RUN:
            jouer_animation("run")

        Etat.JUMP:
            jouer_animation("jump")

        Etat.DASH:
            jouer_animation("dash")


func jouer_animation(nom: String):
    if animated_sprite.animation != nom:
        animated_sprite.play(nom)
