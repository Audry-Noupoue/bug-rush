
extends StaticBody2D

@onready var terrain: TileMapLayer = $Terrain
@onready var collision: CollisionShape2D = $CollisionShape2D

const TAILLE_TUILE = 64


func configurer(largeur: float, hauteur: float) -> void:
	terrain.clear()

	var colonnes = maxi(3, ceili(largeur / TAILLE_TUILE))
	var lignes = maxi(2, ceili(hauteur / TAILLE_TUILE))

	# Construire le terrain tuile par tuile
	for y in range(lignes):
		for x in range(colonnes):
			var colonne_atlas = 1

			if x == 0:
				colonne_atlas = 0
			elif x == colonnes - 1:
				colonne_atlas = 2

			var ligne_atlas = 1

			if y == 0:
				ligne_atlas = 0

			terrain.set_cell(
				Vector2i(x, y),
				0,
				Vector2i(colonne_atlas, ligne_atlas)
			)

	# Adapter la collision au terrain
	var largeur_reelle = colonnes * TAILLE_TUILE
	var hauteur_reelle = lignes * TAILLE_TUILE

	var rectangle = RectangleShape2D.new()
	rectangle.size = Vector2(largeur_reelle, hauteur_reelle)

	collision.shape = rectangle
	collision.position = Vector2(
		largeur_reelle / 2.0,
		hauteur_reelle / 2.0
	)
