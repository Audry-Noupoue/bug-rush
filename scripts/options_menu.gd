class_name OptionsMenu
extends Control

signal closed

@onready var slider_musique: HSlider = %SliderMusique
@onready var slider_effets: HSlider = %SliderEffets
@onready var fullscreen_check: CheckBox = %FullscreenCheck
@onready var back_button: Button = %BackButton

var music_bus: int = AudioServer.get_bus_index("Music")
var sfx_bus: int = AudioServer.get_bus_index("SFX")


func _ready() -> void:
    slider_musique.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
    slider_effets.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))

    slider_musique.value_changed.connect(_on_musique_changed)
    slider_effets.value_changed.connect(_on_effets_changed)
    fullscreen_check.toggled.connect(_on_fullscreen_toggled)
    back_button.pressed.connect(_on_back_pressed)


func open() -> void:
    show()
    slider_musique.grab_focus()


func _on_musique_changed(value: float) -> void:
    AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))


func _on_effets_changed(value: float) -> void:
    AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))


func _on_fullscreen_toggled(enabled: bool) -> void:
    if enabled:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_back_pressed() -> void:
    hide()
    closed.emit()