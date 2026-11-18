
extends "res://scripts/main.gd"


func _ready() -> void:
	super._ready()

	# Araignee plus rapide pour le niveau 2
	araignee.vitesse_patrouille = 90.0
	araignee.vitesse_poursuite = 170.0
	araignee.distance_detection = 330.0

	# Restaurer la progression du niveau 1
	var progression: Dictionary = get_tree().get_meta("progression_bug_rush", {})

	score = int(progression.get("score", 0))
	vies = int(progression.get("vies", 3))
	temps = float(progression.get("temps", 0.0))

	actualiser_score()
	actualiser_vies()
