extends Area2D
signal criquet_touche

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Criquet":
		criquet_touche.emit()
