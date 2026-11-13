extends Control

# Algorithme 3 : projection des coordonnees du monde vers une carte 2D.
# La carte est recalculee depuis les sections generees, sans image prefaite.
@export var largeur_carte: float = 260.0
@export var hauteur_carte: float = 105.0

var terrain
var criquet: Node2D
var araignee: Node2D
var arrivee: Node2D
var obstacles: Node2D
var debut_x: float = 0.0
var fin_x: float = 1.0
var bas_y: float = 620.0
var haut_y: float = 200.0

func initialiser(generateur, joueur: Node2D, ennemi: Node2D, fin: Node2D) -> void:
	terrain = generateur
	criquet = joueur
	araignee = ennemi
	arrivee = fin
	if terrain.zones_plateformes.is_empty():
		return
	debut_x = minf(0.0, float(terrain.zones_plateformes[0]["x"]) - 100.0)
	var derniere: Dictionary = terrain.zones_plateformes.back()
	fin_x = float(derniere["x"]) + float(derniere["largeur"]) + 100.0
	# Inclure les plateformes hautes et les objets dans les limites de la carte.
	for objet in terrain.get_children():
		if objet is Node2D:
			haut_y = minf(haut_y, objet.global_position.y - 40.0)
			bas_y = maxf(bas_y, objet.global_position.y + 40.0)
	queue_redraw()

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

func projeter(position_monde: Vector2) -> Vector2:
	var x: float = (position_monde.x - debut_x) / maxf(1.0, fin_x - debut_x)
	var y: float = (position_monde.y - haut_y) / maxf(1.0, bas_y - haut_y)
	return Vector2(10.0 + clampf(x, 0.0, 1.0) * (largeur_carte - 20.0), 10.0 + clampf(y, 0.0, 1.0) * (hauteur_carte - 20.0))

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(largeur_carte, hauteur_carte)), Color(0.055, 0.11, 0.14, 0.88), true)
	draw_rect(Rect2(Vector2.ZERO, Vector2(largeur_carte, hauteur_carte)), Color(0.45, 0.83, 0.63), false, 2.0)
	if terrain == null or terrain.zones_plateformes.is_empty():
		return
	for zone in terrain.zones_plateformes:
		var x: float = float(zone["x"])
		var y: float = float(zone["y"])
		var largeur: float = float(zone["largeur"])
		var a: Vector2 = projeter(Vector2(x, y))
		var b: Vector2 = projeter(Vector2(x + largeur, y))
		draw_line(a, b, Color(0.35, 0.88, 0.43), 4.0)
	# Tous les objets sont lus dans le terrain genere : pas de liste fixe.
	# Les plateformes mobiles sont reprojetees a chaque frame.
	for enfant in terrain.get_children():
		if not enfant is Node2D:
			continue
		var pos: Vector2 = enfant.global_position
		var nom: String = enfant.name.to_lower()
		if nom.begins_with("plateforme"):
			var collision = enfant.get_node_or_null("CollisionShape2D")
			var demi_largeur: float = 100.0
			if collision != null and collision.shape is RectangleShape2D:
				demi_largeur = collision.shape.size.x * 0.5 * absf(enfant.global_scale.x)
			draw_line(projeter(pos + Vector2(-demi_largeur, 0)), projeter(pos + Vector2(demi_largeur, 0)), Color(0.35, 0.8, 1.0), 2.5)
		elif nom.begins_with("pont"):
			var demi_pont: float = 60.0 * absf(enfant.global_scale.x)
			draw_line(projeter(pos + Vector2(-demi_pont, 0)), projeter(pos + Vector2(demi_pont, 0)), Color(0.75, 0.54, 0.29), 2.0)
		elif nom.begins_with("rocher"):
			draw_rect(Rect2(projeter(pos) - Vector2(3.0, 3.0), Vector2(6.0, 6.0)), Color(0.7, 0.7, 0.76), true)
		elif nom.begins_with("pics"):
			draw_circle(projeter(pos), 3.5, Color(1.0, 0.25, 0.24))
		elif nom.begins_with("champignon"):
			draw_circle(projeter(pos), 2.5, Color(0.85, 0.35, 0.85))
		elif nom.begins_with("medaille"):
			draw_circle(projeter(pos), 2.0, Color(1.0, 0.86, 0.15))
		# Les medailles placees sur les plateformes sont aussi affichees.
		if nom.begins_with("plateforme"):
			for objet in enfant.get_children():
				if objet is Node2D and objet.name.to_lower().begins_with("medaille"):
					draw_circle(projeter(objet.global_position), 2.0, Color(1.0, 0.86, 0.15))
	if arrivee != null:
		draw_circle(projeter(arrivee.global_position), 4.0, Color(1.0, 0.88, 0.3))
	if araignee != null:
		draw_circle(projeter(araignee.global_position), 4.0, Color(1.0, 0.25, 0.36))
	if criquet != null:
		var p: Vector2 = projeter(criquet.global_position)
		draw_circle(p, 5.0, Color(0.2, 0.75, 1.0))
		draw_arc(p, 7.0, 0.0, TAU, 16, Color.WHITE, 1.0)
