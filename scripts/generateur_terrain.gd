extends Node2D

var plateforme_scene = preload("res://scenes/levels/plateforme.tscn")
var medaille_scene = preload("res://scenes/objets/medaille.tscn")
var section_sol_scene = preload("res://scenes/levels/section_sol.tscn")
var pont_scene = preload("res://scenes/levels/pont_bois.tscn")
var champignon_scene = preload("res://scenes/objets/champignon_toxique.tscn")

signal medaille_ramassee
signal champignon_touche

var zones_plateformes = []
var positions_plateformes = []
var zones_occupees = []


func _ready():
    generer_sol()
    generer_plateformes()
    generer_plateformes_passage()


func generer_champignon(position_x: float, largeur_sol: float, hauteur_sol: float):
    # 30 % de chances d'apparition
    if randi_range(1, 10) > 3:
        return

    # Eviter les bords du terrain
    if largeur_sol <= 160:
        return

    var x = randf_range(
        position_x + 80,
        position_x + largeur_sol - 80
    )

    # Creer le champignon
    var champignon = champignon_scene.instantiate()
    add_child(champignon)

    # Placer le bas du champignon sur l'herbe
    champignon.position = Vector2(x, hauteur_sol - 40)

    # Connecter son signal au generateur
    champignon.criquet_touche.connect(
        _on_champignon_touche
    )


func _on_champignon_touche():
    champignon_touche.emit()




func generer_plateformes():
    

    for zone in zones_plateformes:
        # 70 % de chances de creer une plateforme
        if randi_range(1, 10) > 7:
            continue

        var largeur_sol = zone["largeur"]
        var position_sol_x = zone["x"]
        var hauteur_sol = zone["y"]

        if largeur_sol < 250:
            continue

        var position_x = randf_range(
            position_sol_x + 100,
            position_sol_x + largeur_sol - 100
        )

        var position_y = hauteur_sol - randf_range(120.0, 200.0)

        # Choisir le type de plateforme
        var type_plateforme = randi_range(0, 2)

        var direction = Vector2.ZERO
        var distance = 0.0

        if type_plateforme == 1:
            direction = Vector2.RIGHT
            distance = 60.0

        elif type_plateforme == 2:
            direction = Vector2.UP
            distance = 60.0

        # Calculer toute la zone de mouvement
        var depart = Vector2(position_x, position_y)
        var arrivee = depart + direction * distance

        var zone_mouvement = Rect2(
            Vector2(
                minf(depart.x, arrivee.x) - 120.0,
                minf(depart.y, arrivee.y) - 35.0
            ),
            Vector2(
                absf(arrivee.x - depart.x) + 240.0,
                absf(arrivee.y - depart.y) + 70.0
            )
        )

        # Verifier les chevauchements
        var chevauchement = false

        for ancienne_zone in zones_occupees:
            if zone_mouvement.intersects(ancienne_zone):
                chevauchement = true
                break

        if chevauchement:
            continue

        # Creer la plateforme
        var plateforme = plateforme_scene.instantiate()

        plateforme.mobile = type_plateforme != 0
        plateforme.direction_mouvement = direction
        plateforme.distance = distance
        plateforme.vitesse = randf_range(30.0, 60.0)

        plateforme.position = depart
        add_child(plateforme)
        positions_plateformes.append(plateforme.position)

        zones_occupees.append(zone_mouvement)

        # Ajouter une medaille
        var medaille = medaille_scene.instantiate()
        plateforme.add_child(medaille)
        medaille.position = Vector2(0, -50)
        medaille.medaille_ramassee.connect(_on_medaille_ramassee)



func generer_plateformes_passage():
    for i in range(zones_plateformes.size() - 1):
        var zone_actuelle = zones_plateformes[i]
        var zone_suivante = zones_plateformes[i + 1]

        var fin_sol = zone_actuelle["x"] + zone_actuelle["largeur"]
        var debut_sol_suivant = zone_suivante["x"]

        var largeur_trou = debut_sol_suivant - fin_sol

        if largeur_trou < 50:
            continue

        if randi_range(0, 1) == 0:
            continue

        var position_x = (fin_sol + debut_sol_suivant) / 2.0

        var hauteur_sol = minf(
            zone_actuelle["y"],
            zone_suivante["y"]
        )

        var position_y = hauteur_sol - 100.0

        # Verifier la distance avant de creer la plateforme
        var trop_proche = false

        for ancienne_position in positions_plateformes:
            if ancienne_position.distance_to(Vector2(position_x, position_y)) < 220:
                trop_proche = true
                break

        if trop_proche:
            continue

        var plateforme = plateforme_scene.instantiate()
        plateforme.mobile = false
        plateforme.position = Vector2(position_x, position_y)

        add_child(plateforme)
        positions_plateformes.append(plateforme.position)




func generer_sol():
    var position_x = 1024.0
    var bas_sol = 896.0
    var hauteur_surface = 448.0

    for i in range(12):
        var largeur_sol = randi_range(5, 9) * 64

        var epaisseur_sol = bas_sol - hauteur_surface

        var section = section_sol_scene.instantiate()
        add_child(section)

        section.position = Vector2(
            position_x,
            hauteur_surface
        )

        section.configurer(largeur_sol, epaisseur_sol)

        generer_champignon(position_x, largeur_sol, hauteur_surface)

        zones_plateformes.append({
            "x": position_x,
            "largeur": largeur_sol,
            "y": hauteur_surface
        })

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

        var prochaine_hauteur = hauteur_surface

        if i < 11:
            prochaine_hauteur += randi_range(-1, 1) * 64
            prochaine_hauteur = clamp(
                prochaine_hauteur,
                384.0,
                512.0
            )

        var largeur_trou = 64.0

        if i < 11:
            if prochaine_hauteur == hauteur_surface:
                if randi_range(0, 1) == 1:
                    var pont = pont_scene.instantiate()
                    add_child(pont)

                    pont.position = Vector2(
                        position_x + largeur_sol + largeur_trou / 2.0,
                        hauteur_surface
                    )

                    pont.scale.x = (largeur_trou + 20.0) / 120.0

        position_x += largeur_sol + largeur_trou
        hauteur_surface = prochaine_hauteur



func _on_medaille_ramassee():
    medaille_ramassee.emit()
