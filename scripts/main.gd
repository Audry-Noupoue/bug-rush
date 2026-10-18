extends Node2D

var vies = 3
var score = 0
var partie_terminee = false
var temps = 0.0

@onready var label_vies = $HUD/LabelVies
@onready var label_temps = $HUD/LabelTemps
@onready var label_score = $HUD/LabelScore



func _ready():
	label_vies.text = "Vies : " + str(vies)
	label_score.text = "Score : " + str(score)



func _process(delta):
	if not partie_terminee:
		temps += delta
		label_temps.text = "Temps : " + str(int(temps)) + " s"


func _on_zone_chute_body_entered(body):
	if body.name == "Criquet" and not partie_terminee:
		vies -= 1
		label_vies.text = "Vies : " + str(vies)

		if vies <= 0:
			partie_terminee = true
			print("GAME OVER")
			get_tree().paused = true
		else:
			body.velocity = Vector2.ZERO
			body.global_position = Vector2(300, 450)


# func _on_medaille_medaille_ramassee():
#     score += 10
#     label_score.text = "Score : " + str(score)

func _on_generateur_terrain_medaille_ramassee() -> void:
	score += 10
	label_score.text = "Score : " + str(score)
