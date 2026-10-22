
extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -600.0
const DASH_SPEED = 650.0
const DASH_DURATION = 0.25

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine = $StateMachine


func _ready() -> void:
	state_machine.demarrer()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Executer le comportement de l'etat actif
	if state_machine.current_state:
		state_machine.current_state.physics_update(delta)

	# Deplacer le criquet apres avoir calcule sa vitesse
	move_and_slide()


func jouer_animation(nom: String) -> void:
	if animated_sprite.animation != nom or not animated_sprite.is_playing():
		animated_sprite.play(nom)
