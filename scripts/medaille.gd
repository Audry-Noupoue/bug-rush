extends Area2D

signal medaille_ramassee

func _on_body_entered(body):
    if body.name == "Criquet":
        medaille_ramassee.emit()
        queue_free()