extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Audio chargé")
	bus = "Music"
	volume_db = 0
	play()
	print("Bus utilisé : ", bus)
	print("Musique en lecture : ", playing)
	process_mode = Node.PROCESS_MODE_ALWAYS


# # Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
# 	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mute") and not event.is_echo():
		var master_bus = AudioServer.get_bus_index("Master")
		var est_muette = AudioServer.is_bus_mute(master_bus)
		AudioServer.set_bus_mute(master_bus, not est_muette)
		get_viewport().set_input_as_handled()