extends Area2D

signal collecte(type_objet: int)
@export var type_objet: int = 0
var pris = false
var invite: Label
var joueur_proche: Node2D
var sprite: Sprite2D
var horloge: float = 0.0
var images: Array[Texture2D] = []

func _ready() -> void:
	body_entered.connect(_contact)
	body_exited.connect(_sortie)
	if type_objet == 1:
		invite = Label.new()
		invite.text = "[E] Libérer"
		invite.position = Vector2(-48, -62)
		invite.hide()
		add_child(invite)
	sprite = Sprite2D.new()
	add_child(sprite)
	if type_objet == 0:
		for i in range(12):
			images.append(load("res://assets/sprites/niveau_2/decoupes/luciole_%d.png" % i) as Texture2D)
	else:
		images.append(load("res://assets/sprites/niveau_2/decoupes/insecte_%d.png" % (int(position.x) % 3)) as Texture2D)
	sprite.texture = images[0]
	sprite.scale = Vector2.ONE * (78.0 / maxf(sprite.texture.get_width(), sprite.texture.get_height()))

func _process(delta: float) -> void:
	if type_objet == 0 and not images.is_empty():
		horloge += delta
		sprite.texture = images[int(horloge * 10.0) % images.size()]

func _contact(body: Node2D) -> void:
	if pris or body.name != "Criquet":
		return
	if type_objet == 1:
		joueur_proche = body
		invite.show()
		return
	_ramasser()

func _sortie(body: Node2D) -> void:
	if body == joueur_proche:
		joueur_proche = null
		invite.hide()

func _unhandled_input(event: InputEvent) -> void:
	if type_objet == 1 and not pris and is_instance_valid(joueur_proche) and event.is_action_pressed("liberer") and not event.is_echo():
		_ramasser()
		get_viewport().set_input_as_handled()

func _ramasser() -> void:
	if pris:
		return
	pris = true
	collecte.emit(type_objet)
	queue_free()
