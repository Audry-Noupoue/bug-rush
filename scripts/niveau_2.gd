extends "res://scripts/main.gd"

var dernier_checkpoint := Vector2(300, 400)

func _ready() -> void:
	super._ready()
	# Checkpoints a intervalles reguliers, sur le terrain procedural.
	var zones: Array = generateur.zones_plateformes
	for i in range(3, zones.size() - 1, 4):
		var zone: Dictionary = zones[i]
		var point := Area2D.new()
		point.set_script(preload("res://scripts/checkpoint.gd"))
		point.position = Vector2(float(zone["x"]) + 95.0, float(zone["y"]))
		add_child(point)
		point.active.connect(_checkpoint_active)
	# Araignee plus rapide pour le niveau 2.
	araignee.vitesse_patrouille = 90.0
	araignee.vitesse_poursuite = 170.0
	araignee.distance_detection = 330.0
	# Restaurer la progression du niveau 1.
	var progression: Dictionary = get_tree().get_meta("progression_bug_rush", {})
	score = int(progression.get("score", 0))
	vies = int(progression.get("vies", 3))
	temps = float(progression.get("temps", 0.0))
	actualiser_score()
	actualiser_vies()

func _checkpoint_active(position_reapparition: Vector2) -> void:
	dernier_checkpoint = position_reapparition

func perdre_vie() -> void:
	if partie_terminee or invulnerable > 0.0:
		return
	vies -= 1
	actualiser_vies()
	if vies <= 0:
		terminer_partie(false)
	else:
		invulnerable = 1.5
		criquet.velocity = Vector2.ZERO
		criquet.global_position = dernier_checkpoint
