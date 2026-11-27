class_name PauseMenu
extends CanvasLayer

@onready var resume_button: Button = %ResumeButton
@onready var options_button: Button = %OptionsButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var options_menu: OptionsMenu = $OptionsMenu


func _ready() -> void:
	hide()

	resume_button.pressed.connect(resume)
	options_button.pressed.connect(options_menu.open)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	options_menu.closed.connect(_on_options_closed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		var main = get_tree().current_scene

		if main.partie_terminee:
			return

		if visible:
			resume()
		else:
			pause()

		get_viewport().set_input_as_handled()


var music_etait_muet: bool = false

func pause() -> void:
	get_tree().paused = true
	music_etait_muet = AudioServer.is_bus_mute(AudioServer.get_bus_index("Music"))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	show()
	resume_button.grab_focus()


func resume() -> void:
	get_tree().paused = false
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), music_etait_muet)
	options_menu.hide()
	hide()


func _on_options_closed() -> void:
	options_button.grab_focus()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), music_etait_muet)
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
