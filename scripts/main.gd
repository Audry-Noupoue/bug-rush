extends Node2D

const SceneFin = preload("res://scripts/game_over_menu.gd")

const RECORD_FILE = "user://bug_rush_records.json"
var vies: int = 3
var score: int = 0
var partie_terminee: bool = false
var temps: float = 0.0
var invulnerable: float = 0.0
var meilleur_score: int = 0
var dernier_checkpoint: Vector2

@onready var criquet: CharacterBody2D = $Criquet
@onready var label_vies: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/LabelVies
@onready var label_temps: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/LabelTemps
@onready var label_score: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/LabelScore
@onready var araignee = $Araignee
@onready var generateur = $GenerateurTerrain
@onready var zone_arrivee: Area2D = $ZoneArrivee
@onready var debug_hud = $DebugHUD
@onready var mini_map = $MiniMap/Carte
@onready var vecteur_criquet: Line2D = $VecteurCriquet
@onready var vecteur_araignee: Line2D = $VecteurAraignee

func _ready() -> void:
	charger_records()
	actualiser_vies()
	actualiser_score()
	araignee.attaque_criquet.connect(_on_araignee_attaque)
	generateur.obstacle_touche.connect(perdre_vie)
	dernier_checkpoint = criquet.global_position

	for checkpoint in get_tree().get_nodes_in_group("checkpoints"):
		checkpoint.active.connect(_checkpoint_active)
	zone_arrivee.body_entered.connect(_on_arrivee)
	# La generation du terrain est terminee apres _ready des enfants.
	if not generateur.zones_plateformes.is_empty():
		var fin = generateur.zones_plateformes.back()
		zone_arrivee.position = Vector2(fin["x"] + fin["largeur"] - 65.0, fin["y"] - 55.0)
	mini_map.initialiser(generateur, criquet, araignee, zone_arrivee)
	vecteur_criquet.visible = false
	vecteur_araignee.visible = false

func _checkpoint_active(position_reapparition: Vector2) -> void:
	dernier_checkpoint = position_reapparition
	print("Checkpoint sauvegarde : ", dernier_checkpoint)	

func _process(delta: float) -> void:
	if partie_terminee:
		return
	temps += delta
	invulnerable = maxf(0.0, invulnerable - delta)
	criquet.modulate.a = 0.45 if invulnerable > 0.0 and int(temps * 12) % 2 == 0 else 1.0
	label_temps.text = "⏱ Temps : %02d:%02d" % [int(temps / 60.0), int(temps) % 60]
	# La zone de chute suit horizontalement le joueur : les chutes
	# restent detectees sur tout le niveau genere.
	$ZoneChute.global_position.x = criquet.global_position.x
	var debug_actif: bool = debug_hud.panel.visible
	vecteur_criquet.visible = debug_actif
	vecteur_araignee.visible = debug_actif
	if debug_actif:
		vecteur_criquet.global_position = criquet.global_position
		vecteur_criquet.points = PackedVector2Array([Vector2.ZERO, criquet.velocity * 0.25])
		vecteur_araignee.global_position = araignee.global_position
		vecteur_araignee.points = PackedVector2Array([Vector2.ZERO, araignee.velocity * 0.25])

func actualiser_vies() -> void:
	label_vies.text = "Vies : " + "❤️".repeat(maxi(vies, 0))

func actualiser_score() -> void:
	label_score.text = "🏅 Score : " + str(score)


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


func _on_araignee_attaque() -> void:
	perdre_vie()

func _on_zone_chute_body_entered(body: Node2D) -> void:
	if body == criquet:
		perdre_vie()

func _on_generateur_terrain_medaille_ramassee() -> void:
	if partie_terminee:
		return
	score += 10
	actualiser_score()

func _on_generateur_terrain_champignon_touche() -> void:
	if partie_terminee:
		return
	score = maxi(0, score - 5)
	actualiser_score()

func _on_arrivee(body: Node2D) -> void:
	if body == criquet and not partie_terminee:
		if scene_est_niveau_2():
			terminer_partie(true)
		else:
			passer_niveau_2()

func scene_est_niveau_2() -> bool:
	return get_tree().current_scene.scene_file_path.ends_with("niveau_2.tscn")

func passer_niveau_2() -> void:
	partie_terminee = true
	get_tree().set_meta("progression_bug_rush", {"score": score, "vies": vies, "temps": temps})
	get_tree().change_scene_to_file.call_deferred("res://scenes/niveau_2.tscn")

func terminer_partie(victoire: bool) -> void:
	if partie_terminee:
		return
	partie_terminee = true
	criquet.modulate.a = 1.0
	if victoire:
		if score > meilleur_score:
			meilleur_score = score
		sauvegarder_records()
	SceneFin.resultat = {
		"victoire": victoire,
		"score": score,
		"temps": temps,
		"meilleur_score": meilleur_score
		
	}
	get_tree().set_meta("victoire", victoire)
	get_tree().change_scene_to_file.call_deferred(
		"res://scenes/game_over_menu.tscn"
	)
func charger_records() -> void:
	if not FileAccess.file_exists(RECORD_FILE):
		return
	var fichier = FileAccess.open(RECORD_FILE, FileAccess.READ)
	if fichier == null:
		return
	var donnees = JSON.parse_string(fichier.get_as_text())
	if donnees is Dictionary:
		meilleur_score = int(donnees.get("meilleur_score", 0))

func sauvegarder_records() -> void:
	var fichier = FileAccess.open(RECORD_FILE, FileAccess.WRITE)
	if fichier != null:
		fichier.store_string(JSON.stringify({"meilleur_score": meilleur_score}))

func _unhandled_key_input(event: InputEvent) -> void:
	# F10 : acces rapide a la scene de fin pour l'evaluation.
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F10:
		if scene_est_niveau_2():
			terminer_partie(true)
		else:
			passer_niveau_2()
		get_viewport().set_input_as_handled()
