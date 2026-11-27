class_name InstructionsMenu
extends Control

signal closed

@onready var back_button: Button = %BackButton


func _ready() -> void:
    if OS.is_debug_build():
        var raccourcis = Label.new()
        raccourcis.text = "DEBUG : K — Fin aléatoire | F12 — RAM / FPS"
        raccourcis.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        raccourcis.add_theme_font_size_override("font_size", 14)
        back_button.get_parent().add_child(raccourcis)
        back_button.get_parent().move_child(raccourcis, back_button.get_index())
    back_button.pressed.connect(_on_back_pressed)


func _unhandled_input(event: InputEvent) -> void:
    if is_visible_in_tree() and event.is_action_pressed("ui_cancel"):
        get_viewport().set_input_as_handled()
        _on_back_pressed()


func open() -> void:
    show()
    back_button.grab_focus()


func _on_back_pressed() -> void:
    hide()
    closed.emit()