extends Node2D

var plateforme_scene = preload("res://scenes/levels/plateforme.tscn")
var medaille_scene = preload("res://scenes/objets/medaille.tscn")
var section_sol_scene = preload("res://scenes/levels/section_sol.tscn")
var pont_scene = preload("res://scenes/levels/pont_bois.tscn")

signal medaille_ramassee
var zones_plateformes = []


func _ready():
    generer_sol()
    generer_plateformes()
    

func generer_plateformes():
    for zone in zones_plateformes:
        if randi_range(0, 1) == 0:
            continue

        var largeur_sol = zone["largeur"]
        var position_sol_x = zone["x"]
        var hauteur_sol = zone["y"]

        var position_x = position_sol_x + largeur_sol / 2.0
        var position_y = hauteur_sol - randi_range(120, 200)

        # Creer la plateforme
        var plateforme = plateforme_scene.instantiate()
        add_child(plateforme)

        plateforme.position = Vector2(position_x, position_y)

        # Une chance sur deux de bouger
        plateforme.mobile = randi_range(0, 1) == 1

        # Distance adaptee a la largeur du terrain
        plateforme.distance = maxf(
            0.0,
            largeur_sol / 2.0 - 120.0
        )

        # Ajouter une medaille
        var medaille = medaille_scene.instantiate()

        # La medaille devient enfant de la plateforme
        plateforme.add_child(medaille)
        medaille.position = Vector2(0, -50)

        medaille.medaille_ramassee.connect(
            _on_medaille_ramassee
        )



func generer_sol():
    var position_x = 1024.0
    var bas_sol = 896.0
    var hauteur_surface = 448.0

    for i in range(12):
        var largeur_sol = randi_range(5, 9) * 64

        # Calculer la hauteur de la section actuelle
        var epaisseur_sol = bas_sol - hauteur_surface

        # Creer le terrain
        var section = section_sol_scene.instantiate()
        add_child(section)

        section.position = Vector2(
            position_x,
            hauteur_surface
        )

        section.configurer(largeur_sol, epaisseur_sol)

        zones_plateformes.append({
            "x": position_x,
            "largeur": largeur_sol,
            "y": hauteur_surface
        })

        # Ajouter parfois une medaille
        if randi_range(0, 1) == 1:
            var medaille = medaille_scene.instantiate()

            medaille.position = Vector2(
                position_x + largeur_sol / 2.0,
                hauteur_surface - 60
            )

            add_child(medaille)

            medaille.medaille_ramassee.connect(
                _on_medaille_ramassee
            )

        # Calculer la hauteur de la prochaine section
        var prochaine_hauteur = hauteur_surface

        if i < 11:
            prochaine_hauteur += randi_range(-1, 1) * 64
            prochaine_hauteur = clamp(
                prochaine_hauteur,
                384.0,
                512.0
            )

        # Choisir le type de passage
        var largeur_trou = 64.0

        if i < 11:
            if prochaine_hauteur == hauteur_surface:
                # Pont aleatoire entre deux sections
                if randi_range(0, 1) == 1:
                    var pont = pont_scene.instantiate()
                    add_child(pont)

                    pont.position = Vector2(
                        position_x + largeur_sol + largeur_trou / 2.0,
                        hauteur_surface
                    )

                    pont.scale.x = (largeur_trou + 20.0) / 120.0

        # Passer a la prochaine section
        position_x += largeur_sol + largeur_trou
        hauteur_surface = prochaine_hauteur



func _on_medaille_ramassee():
    medaille_ramassee.emit()
