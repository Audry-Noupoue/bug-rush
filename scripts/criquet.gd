
extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -600.0

@onready var animated_sprite = $AnimatedSprite2D


func _physics_process(delta):
    if not is_on_floor():
        velocity += get_gravity() * delta

    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    var direction = Input.get_axis("ui_left", "ui_right")

    if direction:
        velocity.x = direction * SPEED
    else:
        velocity.x = 0

    move_and_slide()

    # Retourner le criquet
    if direction > 0:
        animated_sprite.flip_h = false
    elif direction < 0:
        animated_sprite.flip_h = true

    # Choisir l'animation
    if not is_on_floor():
        jouer_animation("jump")
    elif direction != 0:
        jouer_animation("run")
    else:
        jouer_animation("idle")


func jouer_animation(nom: String):
    if animated_sprite.animation != nom:
        animated_sprite.play(nom)
