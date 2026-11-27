extends "res://scripts/main.gd"

var quete = preload("res://scripts/quete.gd").new()
var label_quete: Label

func _ready() -> void:
	super._ready()
	criquet.JUMP_VELOCITY = -850.0
	zone_arrivee.position = generateur.point(1480, 748)
	mini_map.initialiser(generateur, criquet, araignee, zone_arrivee)
	mini_map.debut_x = 0.0
	mini_map.fin_x = 2508.0
	mini_map.bas_y = 1411.5
	mini_map.haut_y = 0.0
	var camera: Camera2D = criquet.get_node("Camera2D")
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 2508
	camera.limit_bottom = 1412
	camera.drag_vertical_enabled = false
	araignee.vitesse_patrouille = 90.0
	araignee.vitesse_poursuite = 170.0
	araignee.distance_detection = 330.0
	add_child(quete)
	label_quete = Label.new()
	label_quete.hide()
	label_quete.add_theme_color_override("font_color", Color.GOLD)
	label_score.get_parent().add_child(label_quete)
	for objet in generateur.objets_quete:
		objet.collecte.connect(quete.collecter)
	quete.progression_changee.connect(actualiser_quete)
	actualiser_quete()

func actualiser_quete() -> void:
	label_quete.text = quete.texte()
	zone_arrivee.get_node("Texte").text = "ARRIVÉE" if quete.terminee() else "SORTIE VERROUILLÉE"
	zone_arrivee.modulate = Color.WHITE if quete.terminee() else Color(0.5, 0.5, 0.5, 0.6)
	if quete.terminee() and zone_arrivee.overlaps_body(criquet):
		terminer_partie(true)

func sortie_accessible() -> bool:
	return quete.terminee()

func _on_arrivee(body: Node2D) -> void:
	if body == criquet and not quete.terminee():
		afficher_message_sortie()
		return
	super._on_arrivee(body)

func afficher_message_sortie() -> void:
	var texte_sortie = zone_arrivee.get_node_or_null("Texte")
	if texte_sortie != null:
		texte_sortie.text = "Quête incomplète — P : options"
