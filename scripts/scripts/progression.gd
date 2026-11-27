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
