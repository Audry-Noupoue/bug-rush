extends Node2D

signal medaille_ramassee
signal champignon_touche
signal obstacle_touche
var zones_plateformes: Array[Dictionary] = []
var objets_quete: Array[Area2D] = []
var total_medailles: int = 0
@onready var son_medaille: AudioStreamPlayer = $SonMedaille

func _ready() -> void:
	# Plan fixe : trois galeries reliées par des escaliers aux extrémités.
	sol(0, 500, 2400)
	sol(0, 250, 1950)
	sol(450, 0, 1950)
	bloc(Rect2(-40, -220, 40, 760))
	bloc(Rect2(2400, -220, 40, 760))
	bloc(Rect2(0, -220, 2400, 35))
	for p in [Vector2(2200, 375), Vector2(200, 125)]:
		sol(p.x, p.y, 140)
	# Les embranchements imposent des détours, sans condamner les passages.
	for p in [Vector2(800, 500), Vector2(1450, 250), Vector2(1100, 0)]:
		bloc(Rect2(p.x, p.y - 80, 48, 80))
	for p in [Vector2(500, 450), Vector2(1750, 450), Vector2(1600, 200), Vector2(450, 200), Vector2(1600, -50)]:
		objet(p, false)
	for p in [Vector2(1150, 450), Vector2(950, 200), Vector2(750, -50)]:
		objet(p, true)
	for p in [Vector2(350, 450), Vector2(1000, 450), Vector2(2050, 450), Vector2(1750, 200), Vector2(650, 200), Vector2(250, 200), Vector2(950, -50), Vector2(1950, -50)]:
		var m = preload("res://scenes/objets/medaille.tscn").instantiate()
		m.position = p
		m.medaille_ramassee.connect(_medaille_collectee)
		add_child(m)
		m.add_to_group("medailles")
		total_medailles += 1
	for p in [Vector2(2100, 500), Vector2(300, 250), Vector2(1300, 0)]:
		var c = preload("res://scenes/objets/checkpoint.tscn").instantiate()
		c.position = p
		add_child(c)

func sol(x: float, y: float, largeur: float) -> void:
	bloc(Rect2(x, y, largeur, 32))
	zones_plateformes.append({"x": x, "y": y, "largeur": largeur})

func bloc(r: Rect2) -> void:
	var corps = StaticBody2D.new()
	corps.position = r.position + r.size / 2.0
	var collision = CollisionShape2D.new()
	var forme = RectangleShape2D.new()
	forme.size = r.size
	collision.shape = forme
	corps.add_child(collision)
	var visuel = Polygon2D.new()
	var d = r.size / 2.0
	visuel.polygon = PackedVector2Array([Vector2(-d.x,-d.y), Vector2(d.x,-d.y), d, Vector2(-d.x,d.y)])
	visuel.color = Color("263b50")
	corps.add_child(visuel)
	var bord = Line2D.new()
	bord.points = PackedVector2Array([Vector2(-d.x,-d.y), Vector2(d.x,-d.y)])
	bord.width = 5
	bord.default_color = Color("67a995")
	corps.add_child(bord)
	add_child(corps)

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
