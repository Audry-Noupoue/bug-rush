extends CanvasLayer

@onready var panel: PanelContainer = $PanelContainer
@onready var label_fps: Label = $PanelContainer/VBoxContainer/GridContainer/ValueFPS
@onready var label_ram: Label = $PanelContainer/VBoxContainer/GridContainer/ValueRAM
@onready var label_min: Label = $PanelContainer/VBoxContainer/GridContainer/ValueRAMMin
@onready var label_max: Label = $PanelContainer/VBoxContainer/GridContainer/ValueRAMMax

var ram_min: float = INF
var ram_max: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug") and not event.is_echo():
		panel.visible = not panel.visible
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	var ram = Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0

	ram_min = min(ram_min, ram)
	ram_max = max(ram_max, ram)

	label_fps.text = str(Engine.get_frames_per_second())
	label_ram.text = "%.1f MB" % ram
	label_min.text = "%.1f MB" % ram_min
	label_max.text = "%.1f MB" % ram_max