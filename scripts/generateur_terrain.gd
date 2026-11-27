
extends Node2D

@export var plateforme_scene: PackedScene = preload("res://scenes/levels/plateforme.tscn")
@export var champignon_scene: PackedScene = preload("res://scenes/objets/champignon_toxique.tscn")
@export var checkpoint_scene: PackedScene = preload("res://scenes/objets/checkpoint.tscn")
@export var rocher_scene: PackedScene = preload("res://scenes/objets/rocher.tscn")
@export var pics_scene: PackedScene = preload("res://scenes/objets/pics.tscn")

var medaille_scene = preload("res://scenes/objets/medaille.tscn")
var section_sol_scene = preload("res://scenes/levels/section_sol.tscn")
var pont_scene = preload("res://scenes/levels/pont_bois.tscn")

@onready var son_medaille: AudioStreamPlayer = $SonMedaille

signal medaille_ramassee
signal champignon_touche
signal obstacle_touche

@export var nombre_sections: int = 12
@export var probabilite_obstacles: float = 1.0
@export var marge_securite: float = 15.0

var total_medailles: int = 0
var zones_plateformes = []
var positions_plateformes = []
var zones_occupees: Array[Rect2] = []


func _ready():
	reserver_zone_araignee()
	generer_sol()
	var zone = zones_plateformes[zones_plateformes.size() >> 1]
	reserver_zone(Rect2(zone["x"] + zone["largeur"] / 2.0 - 100.0, zone["y"] - 110.0, 200.0, 110.0))
	generer_objets_quete()
	generer_checkpoints()
	generer_champignons()
	generer_plateformes()
	generer_plateformes_passage()
	generer_obstacles()
	generer_medailles_sol()


# Verifier si une zone est disponible
func zone_disponible(zone: Rect2) -> bool:
	for ancienne_zone in zones_occupees:
		if zone.grow(marge_securite).intersects(ancienne_zone):
			return false

	return true


# Reserver une zone
func reserver_zone(zone: Rect2) -> void:
	zones_occupees.append(zone)


# GENERATION DES CHECKPOINTS

func creer_checkpoint(x: float, hauteur_sol: float) -> void:
	var zone = Rect2(
		Vector2(x - 40, hauteur_sol - 120),
		Vector2(120, 120)
	)

	if not zone_disponible(zone):
		return

	var checkpoint = checkpoint_scene.instantiate()
	checkpoint.position = Vector2(x, hauteur_sol)
	add_child(checkpoint)

	reserver_zone(zone)


func generer_checkpoints() -> void:
	for i in range(zones_plateformes.size()):
		if i > 0 and i % 4 == 0:
			var zone: Dictionary = zones_plateformes[i]

			var x: float = float(zone["x"]) + float(zone["largeur"]) / 2.0
			var y: float = float(zone["y"])

			creer_checkpoint(x, y)


# GENERATION DES CHAMPIGNONS

func generer_champignons() -> void:
	for zone in zones_plateformes:
		generer_champignon(
			zone["x"],
			zone["largeur"],
			zone["y"]
		)


func generer_champignon(position_x: float, largeur_sol: float, hauteur_sol: float):
	if randi_range(1, 10) > 3:
		return

	if largeur_sol <= 160:
		return

	# Essayer plusieurs positions
	for tentative in range(5):
		var x = randf_range(
			position_x + 80,
			position_x + largeur_sol - 80
		)

		var zone = Rect2(
			Vector2(x - 40, hauteur_sol - 90),
			Vector2(80, 90)
		)

		if not zone_disponible(zone):
			continue

		var champignon = champignon_scene.instantiate()
		champignon.position = Vector2(x, hauteur_sol - 40)
		add_child(champignon)

		champignon.criquet_touche.connect(
			_on_champignon_touche
		)

		reserver_zone(zone)
		return


func _on_champignon_touche():
	champignon_touche.emit()


# GENERATION DES PLATEFORMES

func generer_plateformes():
	for zone in zones_plateformes:
		# 70 % de chances de creer une plateforme
		if randi_range(1, 10) > 7:
			continue

		var largeur_sol = zone["largeur"]
		var position_sol_x = zone["x"]
		var hauteur_sol = zone["y"]

		if largeur_sol < 250:
			continue

		var position_x = randf_range(
			position_sol_x + 100,
			position_sol_x + largeur_sol - 100
		)

		var position_y = hauteur_sol - randf_range(120.0, 200.0)

		var type_plateforme = randi_range(0, 2)

		var direction = Vector2.ZERO
		var distance = 0.0

		if type_plateforme == 1:
			direction = Vector2.RIGHT
			distance = 60.0

		elif type_plateforme == 2:
			direction = Vector2.UP
			distance = 60.0

		var depart = Vector2(position_x, position_y)
		var arrivee = depart + direction * distance

		# Reserver le trajet de la plateforme et sa medaille
		var zone_mouvement = Rect2(
			Vector2(
				minf(depart.x, arrivee.x) - 120.0,
				minf(depart.y, arrivee.y) - 80.0
			),
			Vector2(
				absf(arrivee.x - depart.x) + 240.0,
				absf(arrivee.y - depart.y) + 115.0
			)
		)

		if not zone_disponible(zone_mouvement):
			continue

		var plateforme = plateforme_scene.instantiate()

		plateforme.mobile = type_plateforme != 0
		plateforme.direction_mouvement = direction
		plateforme.distance = distance
		plateforme.vitesse = randf_range(30.0, 60.0)

		plateforme.position = depart
		add_child(plateforme)

		positions_plateformes.append(plateforme.position)
		reserver_zone(zone_mouvement)

		# Ajouter une medaille sur la plateforme
		var medaille = medaille_scene.instantiate()
		total_medailles += 1
		medaille.position = Vector2(0, -50)
		plateforme.add_child(medaille)

		medaille.medaille_ramassee.connect(
			_on_medaille_ramassee
		)


# GENERATION DES PLATEFORMES DE PASSAGE

func generer_plateformes_passage():
	for i in range(zones_plateformes.size() - 1):
		var zone_actuelle = zones_plateformes[i]
		var zone_suivante = zones_plateformes[i + 1]

		var fin_sol = zone_actuelle["x"] + zone_actuelle["largeur"]
		var debut_sol_suivant = zone_suivante["x"]

		var largeur_trou = debut_sol_suivant - fin_sol

		if largeur_trou < 50:
			continue

		if randi_range(0, 1) == 0:
			continue

		var position_x = (fin_sol + debut_sol_suivant) / 2.0

		var hauteur_sol = minf(
			zone_actuelle["y"],
			zone_suivante["y"]
		)

		var position_y = hauteur_sol - 100.0

		var position_plateforme = Vector2(
			position_x,
			position_y
		)

		var zone_passage = Rect2(
			position_plateforme - Vector2(120, 35),
			Vector2(240, 70)
		)

		if not zone_disponible(zone_passage):
			continue

		var trop_proche = false

		for ancienne_position in positions_plateformes:
			if ancienne_position.distance_to(position_plateforme) < 220:
				trop_proche = true
				break

		if trop_proche:
			continue

		var plateforme = plateforme_scene.instantiate()
		plateforme.mobile = false
		plateforme.position = position_plateforme

		add_child(plateforme)

		positions_plateformes.append(plateforme.position)
		reserver_zone(zone_passage)


# GENERATION DU SOL

func generer_sol():
	var position_x = 105.0
	var bas_sol = 896.0
	var hauteur_surface = 448.0

	for i in range(nombre_sections):
		var largeur_sol = randi_range(5, 9) * 64

		var epaisseur_sol = bas_sol - hauteur_surface

		var section = section_sol_scene.instantiate()
		add_child(section)

		section.position = Vector2(
			position_x,
			hauteur_surface
		)

		section.configurer(largeur_sol, epaisseur_sol)

		zones_plateformes.append({
			"x": position_x,
			"largeur": largeur_sol,
			"y": hauteur_surface
		})

		var prochaine_hauteur = hauteur_surface

		if i < nombre_sections - 1:
			prochaine_hauteur += randi_range(-1, 1) * 64

			prochaine_hauteur = clamp(
				prochaine_hauteur,
				384.0,
				512.0
			)

		var largeur_trou = 64.0

		if i < nombre_sections - 1:
			if prochaine_hauteur == hauteur_surface:
				if randi_range(0, 1) == 1:
					var pont = pont_scene.instantiate()

					pont.position = Vector2(
						position_x + largeur_sol + largeur_trou / 2.0,
						hauteur_surface
					)

					pont.scale.x = (largeur_trou + 20.0) / 120.0

					add_child(pont)

					var zone_pont = Rect2(
						pont.position - Vector2(42, 15),
						Vector2(84, 30)
					)

					reserver_zone(zone_pont)

		position_x += largeur_sol + largeur_trou
		hauteur_surface = prochaine_hauteur


# GENERATION DES OBSTACLES

func generer_obstacles() -> void:
	for i in range(1, zones_plateformes.size() - 1):
		var zone: Dictionary = zones_plateformes[i]
		var largeur: float = float(zone["largeur"])

		if largeur < 320.0 or randf() > probabilite_obstacles:
			continue

		# Essayer plusieurs positions
		for tentative in range(5):
			var x: float = float(zone["x"]) + largeur * randf_range(0.35, 0.65)
			var y: float = float(zone["y"])

			var zone_obstacle = Rect2(
				Vector2(x - 60, y - 80),
				Vector2(120, 80)
			)

			if not zone_disponible(zone_obstacle):
				continue

			if i % 5 == 0:
				var pics = pics_scene.instantiate()
				pics.position = Vector2(x, y)
				add_child(pics)

				pics.criquet_touche.connect(
					func(): obstacle_touche.emit()
				)

			else:
				var rocher = rocher_scene.instantiate()
				rocher.position = Vector2(x, y - 26.0)
				add_child(rocher)

			reserver_zone(zone_obstacle)
			break


# GENERATION DES MEDAILLES AU SOL

func generer_medailles_sol() -> void:
	for zone in zones_plateformes:
		if randi_range(0, 1) == 0:
			continue

		var largeur: float = float(zone["largeur"])
		var debut: float = float(zone["x"])
		var hauteur: float = float(zone["y"])

		for tentative in range(5):
			var x = randf_range(
				debut + 60,
				debut + largeur - 60
			)

			var position_medaille = Vector2(
				x,
				hauteur - 60
			)

			var zone_medaille = Rect2(
				position_medaille - Vector2(25, 25),
				Vector2(50, 50)
			)

			if not zone_disponible(zone_medaille):
				continue

			var medaille = medaille_scene.instantiate()
			total_medailles += 1
			medaille.position = position_medaille
			add_child(medaille)

			medaille.medaille_ramassee.connect(
				_on_medaille_ramassee
			)

			reserver_zone(zone_medaille)
			break


func _on_medaille_ramassee():
	medaille_ramassee.emit()
	son_medaille.play()

func reserver_zone_araignee() -> void:
	var araignee = get_parent().get_node_or_null("Araignee")

	if araignee == null:
		return

	var pos = to_local(araignee.global_position)

	var zone = Rect2(
		Vector2(pos.x - 100, pos.y - 80),
		Vector2(200, 180)
	)

	reserver_zone(zone)

func generer_objets_quete() -> void:
	pass
