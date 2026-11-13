extends Control

# Donnees conservees pendant le changement de scene.
static var resultat: Dictionary = {}

@onready var titre: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/Title
@onready var message: Label = $Root/CenterContainer/PanelContainer/VBoxContainer/Message
@onready var rejouer_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/RejouerButton
@onready var menu_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/MenuButton
@onready var quitter_button: Button = $Root/CenterContainer/PanelContainer/VBoxContainer/QuitterButton

func _ready() -> void:
	get_tree().paused = false
	var victoire: bool = bool(resultat.get("victoire", false))
	var score: int = int(resultat.get("score", 0))
	var temps: float = float(resultat.get("temps", 0.0))
	var record: int = int(resultat.get("meilleur_score", 0))
	var record_temps: float = float(resultat.get("meilleur_temps", 0.0))

	titre.text = "VICTOIRE !" if victoire else "GAME OVER"
	titre.add_theme_color_override("font_color", Color(0.6, 1.0, 0.55) if victoire else Color(1.0, 0.45, 0.45))
	var texte: String = "Bravo, tu as atteint l'arrivée !" if victoire else "Tu as perdu toutes tes vies !"
	message.text = "%s\nScore : %d | Temps : %02d:%02d\nRecord : %d | Meilleur temps : %02d:%02d" % [texte, score, int(temps / 60.0), int(temps) % 60, record, int(record_temps / 60.0), int(record_temps) % 60]

	rejouer_button.pressed.connect(_on_rejouer_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	quitter_button.pressed.connect(_on_quitter_pressed)
	rejouer_button.grab_focus()

func _on_rejouer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

func _on_quitter_pressed() -> void:
	get_tree().quit()
