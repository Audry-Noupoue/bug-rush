
@tool
extends Area2D

signal active(position_reapparition: Vector2)

var deja_active: bool = false


func _ready() -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return

	add_to_group("checkpoints")

	monitoring = true
	collision_layer = 0
	collision_mask = 1

	body_entered.connect(_sur_contact)
	queue_redraw()


func _draw() -> void:
	# Mat du drapeau
	draw_line(
		Vector2(0, 0),
		Vector2(0, -110),
		Color(0.85, 0.83, 0.72),
		6.0
	)

	# Jaune avant activation, vert apres activation
	var couleur := Color.GREEN if deja_active else Color.YELLOW

	draw_colored_polygon(
		PackedVector2Array([
			Vector2(3, -108),
			Vector2(65, -88),
			Vector2(3, -65)
		]),
		couleur
	)

	# Boule au sommet
	draw_circle(
		Vector2(0, -110),
		6.0,
		Color.YELLOW
	)


func _sur_contact(corps: Node2D) -> void:
	print("Contact avec : ", corps.name)

	if deja_active or corps.name != "Criquet":
		return

	deja_active = true
	queue_redraw()

	print("Checkpoint activé : ", global_position)
	active.emit(global_position + Vector2(0, -90))
