extends "res://scripts/generateur_terrain.gd"

func _ready() -> void:
	section_sol_scene = preload("res://scenes/levels/section_sol_nuit.tscn")
	nombre_sections = 17
	probabilite_obstacles = 0.85
	super._ready()
