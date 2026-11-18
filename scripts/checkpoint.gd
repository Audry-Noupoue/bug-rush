extends Area2D

signal active(position_reapparition: Vector2)
var deja_active := false

func _ready() -> void:
	monitoring = true
	collision_layer = 0
	collision_mask = 1
	var forme := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(55, 105)
	forme.shape = rectangle
	forme.position = Vector2(0, -55)
	add_child(forme)
	body_entered.connect(_sur_contact)
	queue_redraw()
	add_to_group("checkpoints")

func _draw() -> void:
	draw_line(Vector2(0, 0), Vector2(0, -110), Color(0.85, 0.83, 0.72), 6)
	var couleur := Color(0.3, 1.0, 0.55) if deja_active else Color(1.0, 0.72, 0.2)
	draw_colored_polygon(PackedVector2Array([Vector2(3, -108), Vector2(65, -88), Vector2(3, -65)]), couleur)
	draw_circle(Vector2(0, -111), 6, Color(1.0, 0.92, 0.5))

func _sur_contact(corps: Node2D) -> void:
	if deja_active or corps.name != "Criquet":
		return
	deja_active = true
	queue_redraw()
	active.emit(global_position + Vector2(0, -90))
