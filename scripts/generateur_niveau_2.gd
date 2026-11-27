extends Node2D

signal medaille_ramassee
signal champignon_touche
signal obstacle_touche
var zones_plateformes: Array[Dictionary] = []
var objets_quete: Array[Area2D] = []
var total_medailles: int = 0
@onready var son_medaille: AudioStreamPlayer = $SonMedaille

func point(x: float, y: float) -> Vector2:
	return Vector2(x * 1672.0 / 1648.0, y * 941.0 / 928.0) * 1.5

func _ready() -> void:
	# Positions fixes uniquement : le terrain est dans la scene.
	zones_plateformes.append({"x": point(0, 143).x, "y": point(0, 143).y, "largeur": point(195, 0).x})
	zones_plateformes.append({"x": point(220, 225).x, "y": point(220, 225).y, "largeur": point(90, 0).x})
	zones_plateformes.append({"x": point(465, 143).x, "y": point(465, 143).y, "largeur": point(270, 0).x})
	zones_plateformes.append({"x": point(755, 197).x, "y": point(755, 197).y, "largeur": point(225, 0).x})
	zones_plateformes.append({"x": point(0, 488).x, "y": point(0, 488).y, "largeur": point(330, 0).x})
	zones_plateformes.append({"x": point(350, 390).x, "y": point(350, 390).y, "largeur": point(270, 0).x})
	zones_plateformes.append({"x": point(730, 441).x, "y": point(730, 441).y, "largeur": point(370, 0).x})
	zones_plateformes.append({"x": point(1105, 310).x, "y": point(1105, 310).y, "largeur": point(295, 0).x})
	zones_plateformes.append({"x": point(1420, 220).x, "y": point(1420, 220).y, "largeur": point(228, 0).x})
	zones_plateformes.append({"x": point(1090, 580).x, "y": point(1090, 580).y, "largeur": point(145, 0).x})
	zones_plateformes.append({"x": point(1250, 520).x, "y": point(1250, 520).y, "largeur": point(398, 0).x})
	zones_plateformes.append({"x": point(180, 755).x, "y": point(180, 755).y, "largeur": point(135, 0).x})
	zones_plateformes.append({"x": point(335, 695).x, "y": point(335, 695).y, "largeur": point(155, 0).x})
	zones_plateformes.append({"x": point(510, 637).x, "y": point(510, 637).y, "largeur": point(130, 0).x})
	zones_plateformes.append({"x": point(0, 850).x, "y": point(0, 850).y, "largeur": point(650, 0).x})
	zones_plateformes.append({"x": point(750, 745).x, "y": point(750, 745).y, "largeur": point(170, 0).x})
	zones_plateformes.append({"x": point(1110, 785).x, "y": point(1110, 785).y, "largeur": point(538, 0).x})
	for p in [point(280, 200), point(580, 118), point(850, 172), point(500, 365), point(1450, 495)]:
		objet(p, false)
	for p in [point(1250, 285), point(180, 463), point(1170, 555)]:
		objet(p, true)
	for p in [point(150, 118), point(700, 118), point(950, 172), point(400, 365), point(900, 416), point(1350, 285), point(1500, 495), point(1450, 760)]:
		var m = preload("res://scenes/objets/medaille.tscn").instantiate()
		m.position = p
		m.medaille_ramassee.connect(_medaille_collectee)
		add_child(m)
		m.add_to_group("medailles")
		total_medailles += 1
	for p in [point(520, 143), point(850, 441), point(1450, 520)]:
		var c = preload("res://scenes/objets/checkpoint.tscn").instantiate()
		c.position = p
		add_child(c)

func objet(p: Vector2, prisonnier: bool) -> void:
	var scene = preload("res://scenes/objets/insecte_prisonnier.tscn") if prisonnier else preload("res://scenes/objets/luciole.tscn")
	var o = scene.instantiate() as Area2D
	o.position = p
	add_child(o)
	objets_quete.append(o)
	o.add_to_group("objets_quete")

func _medaille_collectee() -> void:
	son_medaille.play()
	medaille_ramassee.emit()
