extends Control

func _ready() -> void:
	var fond = ColorRect.new()
	fond.color = Color("10251f")
	add_child(fond)
	fond.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var centre = CenterContainer.new()
	add_child(centre)
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var colonne = VBoxContainer.new()
	colonne.add_theme_constant_override("separation", 14)
	centre.add_child(colonne)
	var titre = Label.new()
	titre.text = "BUG RUSH  •  CHOISIS TON NIVEAU"
	titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titre.add_theme_font_size_override("font_size", 28)
	colonne.add_child(titre)
	var ligne = HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 20)
	colonne.add_child(ligne)
	for niveau in [1, 2]:
		var carte = VBoxContainer.new()
		carte.add_theme_constant_override("separation", 8)
		ligne.add_child(carte)
		var image = TextureRect.new()
		image.texture = preload("res://assets/sprites/menu.png") if niveau == 1 else preload("res://assets/sprites/Foret_nocturne.png")
		image.custom_minimum_size = Vector2(245, 135)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		carte.add_child(image)
		var bouton = Button.new()
		bouton.custom_minimum_size = Vector2(245, 48)
		bouton.text = "1 • Course du jardin" if niveau == 1 else "2 • Labyrinthe nocturne"
		bouton.disabled = not Progression.accessible(niveau)
		if bouton.disabled:
			image.modulate.a = 0.30
			var cadenas = Label.new()
			cadenas.text = "🔒"
			cadenas.add_theme_font_size_override("font_size", 48)
			cadenas.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			cadenas.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			image.add_child(cadenas)
			cadenas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			bouton.text = "Niveau 2 • Verrouillé"
		bouton.pressed.connect(Progression.jouer.bind(niveau))
		carte.add_child(bouton)
		if niveau == 1:
			bouton.grab_focus()
		var note = Label.new()
		var n: int = Progression.etoiles(niveau)
		note.text = "★".repeat(n) + "☆".repeat(3 - n)
		note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		note.add_theme_color_override("font_color", Color.GOLD)
		note.add_theme_font_size_override("font_size", 28)
		carte.add_child(note)
	var retour = Button.new()
	retour.text = "MENU PRINCIPAL"
	retour.custom_minimum_size.y = 42
	retour.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menu_principal.tscn"))
	colonne.add_child(retour)
