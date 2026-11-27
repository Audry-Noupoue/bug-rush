
extends CharacterBody2D

signal attaque_criquet

enum Etat { PATROUILLE, POURSUITE, ATTAQUE, RETOUR }

@export var vitesse_patrouille: float = 65.0
@export var vitesse_poursuite: float = 125.0
@export var distance_patrouille: float = 110.0
@export var distance_detection: float = 250.0
@export var distance_attaque: float = 38.0
@export var delai_attaque: float = 1.2
@export var force_saut: float = -500.0
@export var delai_entre_sauts: float = 0.45

@onready var detecteur_obstacle: RayCast2D = $DetecteurObstacle
@onready var detecteur_sol: RayCast2D = $DetecteurSol
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var son_attaque: AudioStreamPlayer2D = get_node_or_null("SonAttaque")

var etat: Etat = Etat.PATROUILLE
var depart: Vector2
var direction: float = 1.0
var temps_attaque: float = 0.0
var criquet: Node2D
var temps_saut: float = 0.0
var temps_bloque: float = 0.0
var derniere_position_x: float = 0.0


func _ready() -> void:
	_configurer_animations()
	depart = global_position
	derniere_position_x = global_position.x
	criquet = get_tree().current_scene.get_node_or_null("Criquet") as Node2D
	add_to_group("araignees")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	temps_attaque = maxf(0.0, temps_attaque - delta)
	temps_saut = maxf(0.0, temps_saut - delta)

	if criquet == null or not is_instance_valid(criquet):
		velocity.x = 0.0
		move_and_slide()
		return

	var distance = global_position.distance_to(criquet.global_position)

	match etat:
		Etat.PATROUILLE:
			if distance <= distance_detection:
				etat = Etat.POURSUITE
			else:
				if absf(global_position.x - depart.x) >= distance_patrouille:
					direction = -1.0 if global_position.x > depart.x else 1.0
				velocity.x = direction * vitesse_patrouille

		Etat.POURSUITE:
			if distance <= distance_attaque:
				etat = Etat.ATTAQUE
			elif distance > distance_detection * 1.5:
				etat = Etat.RETOUR
			else:
				direction = signf(criquet.global_position.x - global_position.x)
				velocity.x = direction * vitesse_poursuite

		Etat.ATTAQUE:
			velocity.x = 0.0

			if distance > distance_attaque:
				etat = Etat.POURSUITE

			elif temps_attaque <= 0.0:
				if son_attaque != null:
					son_attaque.play()
					print("Son attaque joue")
				else:
					print("SonAttaque introuvable")

				attaque_criquet.emit()
				temps_attaque = delai_attaque

		Etat.RETOUR:
			if distance <= distance_detection:
				etat = Etat.POURSUITE
			elif absf(global_position.x - depart.x) <= 8.0:
				velocity.x = 0.0
				etat = Etat.PATROUILLE
			else:
				direction = signf(depart.x - global_position.x)
				velocity.x = direction * vitesse_patrouille

	# Orienter le détecteur dans le sens du déplacement
	if velocity.x != 0.0:
		detecteur_obstacle.target_position.x = signf(velocity.x) * 35.0
		detecteur_sol.position.x = signf(velocity.x) * 35.0
	detecteur_obstacle.force_raycast_update()
	detecteur_sol.force_raycast_update()

	# Analyse de l'environnement et des blocages.
	var obstacle_devant: bool = detecteur_obstacle.is_colliding()
	var bord_devant: bool = not detecteur_sol.is_colliding()
	if absf(global_position.x - derniere_position_x) < 0.6 and absf(velocity.x) > 10.0:
		temps_bloque += delta
	else:
		temps_bloque = 0.0
	derniere_position_x = global_position.x

	
	if is_on_floor() and temps_saut <= 0.0:
		if etat == Etat.POURSUITE:
			var criquet_plus_haut: bool = criquet.global_position.y < global_position.y - 45.0

			if obstacle_devant or bord_devant or criquet_plus_haut or temps_bloque > 0.2:
				velocity.y = force_saut
				temps_saut = delai_entre_sauts

		elif etat == Etat.PATROUILLE or etat == Etat.RETOUR:
			if bord_devant:
				if etat == Etat.PATROUILLE:
					direction *= -1.0
					velocity.x = direction * vitesse_patrouille
				else:
					velocity.x = 0.0

			elif obstacle_devant:
				if etat == Etat.PATROUILLE:
					direction *= -1.0
					velocity.x = direction * vitesse_patrouille
				else:
					velocity.y = force_saut
					temps_saut = delai_entre_sauts

	move_and_slide()
	_mettre_a_jour_animation()



func _configurer_animations() -> void:
	var frames = SpriteFrames.new()
	for nom in ["repos", "marche", "attaque", "mort"]:
		frames.add_animation(nom)
		frames.set_animation_speed(nom, 6.0 if nom == "marche" else 5.0)
		frames.set_animation_loop(nom, nom != "mort")
	var noms = ["repos", "marche", "attaque", "mort"]
	for ligne in range(4):
		for colonne in range(8):
			var chemin = "res://assets/sprites/ennemis_obstacles/araignee_%d_%d.png" % [ligne, colonne]
			frames.add_frame(noms[ligne], load(chemin))
	animation.sprite_frames = frames
	animation.play("repos")


func _mettre_a_jour_animation() -> void:
	var nom = "repos"
	if etat == Etat.ATTAQUE:
		nom = "attaque"
	elif absf(velocity.x) > 5.0:
		nom = "marche"
	if animation.animation != nom:
		animation.play(nom)
	if absf(velocity.x) > 5.0:
		animation.flip_h = velocity.x < 0.0
