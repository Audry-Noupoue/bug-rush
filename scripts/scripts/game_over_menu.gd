extends Control

static var resultat: Dictionary = {}

@onready var titre: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/Title
@onready var message: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/Message
@onready var rejouer_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/RejouerButton
@onready var menu_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/MenuButton
@onready var quitter_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/QuitterButton
@onready var background: TextureRect = $Root/Background
@onready var panneau: PanelContainer = $Root/CenterContainer/PanelContainer

var image_defaite = preload("res://assets/sprites/defaite.png")
var image_victoire = preload("res://assets/sprites/victoire.png")


func _ready() -> void:
	get_tree().paused = false

	var victoire = bool(resultat.get("victoire", false))
	var niveau = int(resultat.get("niveau", 1))
	var etoiles = clampi(int(resultat.get("etoiles", 0)), 0, 3)
	var score = int(resultat.get("score", 0))
	var temps = float(resultat.get("temps", 0.0))

	# Image de fond
	afficher_resultat(victoire)

	# Apparence du panneau
	var style = StyleBoxFlat.new()
	style.bg_color = Color("203b32") if victoire else Color("3b2934")
	style.set_corner_radius_all(18)
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 18
	style.content_margin_bottom = 18

	panneau.add_theme_stylebox_override("panel", style)

	var colonne = message.get_parent()
	colonne.add_theme_constant_override("separation", 8)

	quitter_button.hide()

	# Affichage du titre
	titre.visible = true
	titre.text = "NIVEAU %d TERMINÉ !" % niveau if victoire else "GAME OVER"

	titre.add_theme_color_override(
		"font_color",
		Color(0.6, 1.0, 0.55) if victoire else Color(1.0, 0.45, 0.45)
	)

	# Affichage des statistiques
	var texte: String = "Bravo, tu as atteint l'arrivée !" if victoire else "Tu as perdu toutes tes vies !"

	message.text = "%s\nScore : %d | Temps : %02d:%02d\nMédailles : %d / %d | Vies : %d" % [
		texte,
		score,
		int(temps / 60.0),
		int(temps) % 60,
		int(resultat.get("medailles", 0)),
		int(resultat.get("total_medailles", 0)),
		int(resultat.get("vies", 0))
	]

	# Affichage des étoiles
	if victoire:
		var note = Label.new()
		note.text = "★".repeat(etoiles) + "☆".repeat(3 - etoiles)
		note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		note.add_theme_font_size_override("font_size", 40)
		note.add_theme_color_override("font_color", Color.GOLD)

		colonne.add_child(note)
		colonne.move_child(note, 1)

		# Accès au niveau 2
		if niveau == 1:
			var suivant = Button.new()
			suivant.text = "ACCÉDER AU NIVEAU 2"
			suivant.custom_minimum_size.y = 40
			suivant.pressed.connect(Progression.jouer.bind(2))

			colonne.add_child(suivant)
			colonne.move_child(suivant, rejouer_button.get_index())

	# Bouton de sélection des niveaux
	var selection = Button.new()
	selection.text = "SÉLECTION DES NIVEAUX"
	selection.custom_minimum_size.y = 40
	selection.pressed.connect(_on_selection_pressed)

	colonne.add_child(selection)
	colonne.move_child(selection, menu_button.get_index())

	# Connexion des boutons
	rejouer_button.pressed.connect(_on_rejouer_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	quitter_button.pressed.connect(_on_quitter_pressed)

	rejouer_button.grab_focus()


func _on_rejouer_pressed() -> void:
	Progression.jouer(int(resultat.get("niveau", 1)))


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")


func _on_selection_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/selection_niveaux.tscn")


func _on_quitter_pressed() -> void:
	get_tree().quit()


func afficher_resultat(victoire: bool) -> void:
	background.show()

	if victoire:
		background.texture = image_victoire
	else:
		background.texture = image_defaite

	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
