extends Area2D

signal collecte(type_objet: int)
@export var type_objet: int = 0
var pris = false

func _ready() -> void:
	body_entered.connect(_contact)
	queue_redraw()

func _contact(body: Node2D) -> void:
	if pris or body.name != "Criquet":
		return
	pris = true
	collecte.emit(type_objet)
	queue_free()

func _draw() -> void:
	if type_objet == 0:
		draw_circle(Vector2.ZERO, 24, Color(1, 0.9, 0.2, 0.15))
		draw_circle(Vector2(-9, -5), 8, Color(0.8, 1, 0.8, 0.8))
		draw_circle(Vector2(9, -5), 8, Color(0.8, 1, 0.8, 0.8))
		draw_circle(Vector2.ZERO, 9, Color.GOLD)
	else:
		for i in range(8):
			var angle: float = TAU * i / 8.0
			draw_line(Vector2.ZERO, Vector2.from_angle(angle) * 25, Color.LIGHT_GRAY, 2)
		for rayon in [12, 23]:
			draw_arc(Vector2.ZERO, rayon, 0, TAU, 8, Color.LIGHT_GRAY, 2)
		draw_circle(Vector2.ZERO, 8, Color.CORAL)
