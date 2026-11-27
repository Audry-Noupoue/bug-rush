extends Node

const FICHIER = "user://bug_rush_progression.json"
const NIVEAUX = ["res://scenes/main.tscn", "res://scenes/niveau_2.tscn"]
var donnees: Dictionary = {}

func etoiles(niveau: int) -> int:
	return int(donnees.get(str(niveau), {}).get("etoiles", 0))

func accessible(niveau: int) -> bool:
	return niveau == 1 or (niveau == 2 and etoiles(1) > 0)

func enregistrer(niveau: int, nombre: int, temps: float, score: int) -> void:
	var cle = str(niveau)
	var ancien: Dictionary = donnees.get(cle, {})
	donnees[cle] = {"etoiles": maxi(nombre, etoiles(niveau)), "temps": minf(temps, float(ancien.get("temps", temps))), "score": maxi(score, int(ancien.get("score", 0)))}

func jouer(niveau: int) -> void:
	if accessible(niveau):
		get_tree().change_scene_to_file(NIVEAUX[niveau - 1])

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for action in ["ui_accept", "ui_cancel", "ui_left", "ui_right", "ui_up", "ui_down"]:
		var boutons = {"ui_accept": 0, "ui_cancel": 1, "ui_left": 13, "ui_right": 14, "ui_up": 11, "ui_down": 12}
		var event = InputEventJoypadButton.new()
		event.button_index = boutons[action]
		InputMap.action_add_event(action, event)

var transition_en_cours: bool = false

func _input(event: InputEvent) -> void:
	if not OS.is_debug_build() or not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return
	if event.keycode != KEY_K and event.physical_keycode != KEY_K:
		return
	if transition_en_cours:
		return
	get_viewport().set_input_as_handled()
	transition_en_cours = true
	_fin_test.call_deferred()

func _fin_test() -> void:
	var victoire: bool = randi_range(0, 1) == 1
	var scene = get_tree().current_scene
	var niveau: int = 1
	if scene != null and scene.has_method("scene_est_niveau_2"):
		niveau = 2 if scene.scene_est_niveau_2() else 1
		if scene.partie_terminee:
			transition_en_cours = false
			return
		scene.partie_terminee = true
		var pause_menu = scene.get_node_or_null("PauseMenu")
		if pause_menu != null and pause_menu.visible:
			pause_menu.resume()
	elif accessible(2):
		niveau = 2
	if victoire:
		for n in [1, 2]:
			enregistrer(n, 3, 0.0, 80)
		niveau = 2
	var fin = load("res://scripts/game_over_menu.gd")
	fin.resultat = {"niveau": niveau, "victoire": victoire, "etoiles": 3 if victoire else 0, "temps": 0.0, "score": 80 if victoire else 0, "vies": 3 if victoire else 0, "medailles": 8 if victoire else 0, "total_medailles": 8}
	get_tree().paused = false
	get_tree().set_meta("victoire", victoire)
	var erreur = get_tree().change_scene_to_file("res://scenes/game_over_menu.tscn")
	if erreur != OK:
		push_error("Impossible d'ouvrir la scène de fin : %s" % erreur)
	transition_en_cours = false
