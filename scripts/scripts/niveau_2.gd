extends "res://scripts/main.gd"

var quete = preload("res://scripts/quete.gd").new()
var label_quete: Label

func _ready() -> void:
	super._ready()
	zone_arrivee.position = Vector2(2280, -55)
	mini_map.initialiser(generateur, criquet, araignee, zone_arrivee)
	mini_map.fin_x = 2500.0
	mini_map.haut_y = -250.0
	araignee.vitesse_patrouille = 90.0
	araignee.vitesse_poursuite = 170.0
	araignee.distance_detection = 330.0
	add_child(quete)
	label_quete = Label.new()
	label_quete.add_theme_color_override("font_color", Color.GOLD)
	label_score.get_parent().add_child(label_quete)
	for objet in generateur.objets_quete:
		objet.collecte.connect(quete.collecter)
	quete.progression_changee.connect(actualiser_quete)
	actualiser_quete()

func actualiser_quete() -> void:
	label_quete.text = quete.texte()
	zone_arrivee.modulate = Color.WHITE if quete.terminee() else Color(0.5, 0.5, 0.5, 0.6)
	if quete.terminee() and zone_arrivee.overlaps_body(criquet):
		terminer_partie(true)

func sortie_accessible() -> bool:
	return quete.terminee()

func _on_arrivee(body: Node2D) -> void:
	if body == criquet and not quete.terminee():
		label_quete.text = quete.texte() + "\nTermine la quête avant de sortir !"
		return
	super._on_arrivee(body)
