
class_name MainMenu
extends Control

@onready var jouer_button: Button = %ButtonJouer
@onready var parametres_button: Button = %ButtonParametres
@onready var instructions_button: Button = %ButtonInstructions
@onready var quitter_button: Button = %ButtonQuitter
@onready var options_menu: OptionsMenu = $OptionsMenu
@onready var instructions_menu: InstructionsMenu = $InstructionsMenu


func _ready() -> void:
	jouer_button.pressed.connect(_on_jouer_pressed)
	parametres_button.pressed.connect(_on_parametres_pressed)
	instructions_button.pressed.connect(_on_instructions_pressed)
	quitter_button.pressed.connect(_on_quitter_pressed)
	options_menu.closed.connect(_on_options_closed)
	instructions_menu.closed.connect(_on_instructions_closed)
	jouer_button.grab_focus()


func _on_jouer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/selection_niveaux.tscn")


func _on_parametres_pressed() -> void:
	options_menu.open()


func _on_instructions_pressed() -> void:
	instructions_menu.open()

func _on_instructions_closed() -> void:
	instructions_button.grab_focus()

func _on_quitter_pressed() -> void:
	get_tree().quit()

func _on_options_closed() -> void:
	parametres_button.grab_focus()
