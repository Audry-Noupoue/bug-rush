
extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -600.0

@onready var animated_sprite = $AnimatedSprite2D


func _physics_process(delta):
    if not is_on_floor():
        velocity += get_gravity() * delta

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    var direction = Input.get_axis("move_left", "move_right")

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

func _input(event):
    if event.is_action_pressed("dash"):
        print("DASH activé !")        


func jouer_animation(nom: String):
    if animated_sprite.animation != nom:
        animated_sprite.play(nom)
