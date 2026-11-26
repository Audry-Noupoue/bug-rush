
extends Control


@export var largeur_carte: float = 260.0
@export var hauteur_carte: float = 105.0

var terrain
var criquet: Node2D
var araignee: Node2D
var arrivee: Node2D

var debut_x: float = 0.0
var fin_x: float = 1.0
var bas_y: float = 620.0
var haut_y: float = 200.0


func _ready() -> void:
	custom_minimum_size = Vector2(largeur_carte, hauteur_carte)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func initialiser(generateur, joueur: Node2D, ennemi: Node2D, fin: Node2D) -> void:
	terrain = generateur
	criquet = joueur
	araignee = ennemi
	arrivee = fin

	if terrain == null or terrain.zones_plateformes.is_empty():
		return

	debut_x = minf(0.0, float(terrain.zones_plateformes[0]["x"]) - 100.0)

	var derniere: Dictionary = terrain.zones_plateformes.back()
	fin_x = float(derniere["x"]) + float(derniere["largeur"]) + 100.0

	haut_y = 200.0
	bas_y = 620.0

	for objet in recuperer_objets(terrain):
		haut_y = minf(haut_y, objet.global_position.y - 40.0)
		bas_y = maxf(bas_y, objet.global_position.y + 40.0)

	queue_redraw()


func _process(_delta: float) -> void:
	if visible:
		queue_redraw()


func recuperer_objets(noeud: Node) -> Array[Node2D]:
	var objets: Array[Node2D] = []

	for enfant in noeud.get_children():
		if enfant is Node2D:
			objets.append(enfant)

		objets.append_array(recuperer_objets(enfant))

	return objets


func projeter(position_monde: Vector2) -> Vector2:
	var x: float = (position_monde.x - debut_x) / maxf(1.0, fin_x - debut_x)
	var y: float = (position_monde.y - haut_y) / maxf(1.0, bas_y - haut_y)

	return Vector2(
		10.0 + clampf(x, 0.0, 1.0) * (largeur_carte - 20.0),
		10.0 + clampf(y, 0.0, 1.0) * (hauteur_carte - 20.0)
	)


func dessiner_objet(objet: Node2D, type_objet: String) -> void:
	var pos: Vector2 = objet.global_position

	match type_objet:

		"ponts":
			var demi_pont: float = 60.0 * absf(objet.global_scale.x)

			draw_line(
				projeter(pos + Vector2(-demi_pont, 0)),
				projeter(pos + Vector2(demi_pont, 0)),
				Color(0.75, 0.54, 0.29),
				2.5
			)

		"rochers":
			draw_rect(
				Rect2(projeter(pos) - Vector2(3, 3), Vector2(6, 6)),
				Color.GRAY,
				true
			)

		"piques":
			draw_circle(projeter(pos), 3.5, Color.RED)

		"champignons":
			draw_circle(projeter(pos), 3.0, Color.PURPLE)

		"medailles":
			draw_circle(projeter(pos), 3.0, Color.YELLOW)

		"checkpoints":
			draw_circle(projeter(pos), 4.0, Color.GREEN)

		"araignees":
			draw_circle(projeter(pos), 4.0, Color(1.0, 0.25, 0.36))


func _draw() -> void:
	draw_rect(
		Rect2(Vector2.ZERO, Vector2(largeur_carte, hauteur_carte)),
		Color(0.055, 0.11, 0.14, 0.88),
		true
	)

	draw_rect(
		Rect2(Vector2.ZERO, Vector2(largeur_carte, hauteur_carte)),
		Color(0.45, 0.83, 0.63),
		false,
		2.0
	)

	if terrain == null or not is_instance_valid(terrain):
		return

	if terrain.zones_plateformes.is_empty():
		return

	for zone in terrain.zones_plateformes:
		var x: float = float(zone["x"])
		var y: float = float(zone["y"])
		var largeur: float = float(zone["largeur"])

		draw_line(
			projeter(Vector2(x, y)),
			projeter(Vector2(x + largeur, y)),
			Color(0.35, 0.88, 0.43),
			4.0
		)

	var groupes: Array[String] = [
		"ponts",
		"rochers",
		"piques",
		"champignons",
		"medailles",
		"checkpoints",
		"araignees"
	]

	for groupe in groupes:
		for objet in get_tree().get_nodes_in_group(groupe):
			if objet is Node2D and is_instance_valid(objet):
				dessiner_objet(objet, groupe)

	for objet in recuperer_objets(terrain):
		if objet.name.to_lower().begins_with("medaille"):
			if not objet.is_in_group("medailles"):
				dessiner_objet(objet, "medailles")			

	if araignee != null and is_instance_valid(araignee):
		if not araignee.is_in_group("araignees"):
			dessiner_objet(araignee, "araignees")

	if arrivee != null and is_instance_valid(arrivee):
		draw_circle(
			projeter(arrivee.global_position),
			4.0,
			Color(1.0, 0.88, 0.3)
		)

	if criquet != null and is_instance_valid(criquet):
		var p: Vector2 = projeter(criquet.global_position)

		draw_circle(p, 5.0, Color(0.2, 0.75, 1.0))
		draw_arc(p, 7.0, 0.0, TAU, 16, Color.WHITE, 1.0)
