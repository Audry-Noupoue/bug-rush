class_name OptionsMenu
extends Control

signal closed

@onready var slider_musique: HSlider = %SliderMusique
@onready var slider_effets: HSlider = %SliderEffets
@onready var fullscreen_check: CheckBox = %FullscreenCheck
@onready var back_button: Button = %BackButton

var objectifs: Label

var music_bus: int = AudioServer.get_bus_index("Music")
var sfx_bus: int = AudioServer.get_bus_index("SFX")


func _ready() -> void:
    objectifs = Label.new()
    objectifs.add_theme_font_size_override("font_size", 16)
    back_button.get_parent().add_child(objectifs)
    back_button.get_parent().move_child(objectifs, back_button.get_index())
    slider_musique.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
    slider_effets.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))

    slider_musique.value_changed.connect(_on_musique_changed)
    slider_effets.value_changed.connect(_on_effets_changed)
    fullscreen_check.toggled.connect(_on_fullscreen_toggled)
    back_button.pressed.connect(_on_back_pressed)


func open() -> void:
    var scene = get_tree().current_scene
    objectifs.text = "COMMANDES — CLAVIER / XBOX / PLAYSTATION\nDéplacement : A/D ou flèches / stick gauche ou croix directionnelle\nSaut : Espace / A / Croix     Dash : J / X / Carré\nLibérer : E / B / Cercle     Pause : P / Menu / Options\nMenus : Entrée / A / Croix     Retour : Échap / B / Cercle\n\nOBJECTIFS\nNiveau 1 : médailles et arrivée.\nNiveau 2 : 5 lucioles et 3 insectes, puis sortie.\nÉtoiles : victoire, 70 % des médailles, temps (2 / 3 min)."
    if OS.is_debug_build():
        objectifs.text += "\nTESTS (DEBUG) : K — Fin aléatoire (victoire ou défaite)\nF12 — Afficher / masquer RAM et FPS en jeu."
    if scene.has_method("scene_est_niveau_2") and scene.scene_est_niveau_2():
        objectifs.text += "\n\n" + scene.quete.texte()
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

func _unhandled_input(event: InputEvent) -> void:
    if is_visible_in_tree() and event.is_action_pressed("ui_cancel"):
        _on_back_pressed()
        get_viewport().set_input_as_handled()
