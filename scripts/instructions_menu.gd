class_name InstructionsMenu
extends Control

signal closed

@onready var back_button: Button = %BackButton


func _ready() -> void:
    back_button.pressed.connect(_on_back_pressed)


func open() -> void:
    show()
    back_button.grab_focus()


func _on_back_pressed() -> void:
    hide()
    closed.emit()