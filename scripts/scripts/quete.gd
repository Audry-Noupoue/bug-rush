extends Node

signal progression_changee
const LUCIOLES = 5
const INSECTES = 3
var lucioles = 0
var insectes = 0

func collecter(type_objet: int) -> void:
	if type_objet == 0:
		lucioles += 1
	else:
		insectes += 1
	progression_changee.emit()

func terminee() -> bool:
	return lucioles >= LUCIOLES and insectes >= INSECTES

func texte() -> String:
	return "Quête : sauver la forêt\nLucioles : %d / %d\nInsectes : %d / %d\n%s" % [lucioles, LUCIOLES, insectes, INSECTES, "Sortie ouverte" if terminee() else "Sortie verrouillée"]
