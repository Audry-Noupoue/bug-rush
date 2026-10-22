
extends Area2D

signal criquet_touche

func _ready():
    body_entered.connect(_on_body_entered)


func _on_body_entered(body):
    if body is CharacterBody2D:
        criquet_touche.emit()

