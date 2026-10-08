# Bug Rush 🦗

**Créateur : Audry Noupoue**

## Introduction

Bug Rush est un jeu de plateforme 2D développé avec Godot. Le joueur contrôle un criquet sportif qui participe à une course d'obstacles dans un jardin rempli de plateformes et d'insectes ennemis.

L'objectif est de terminer le parcours le plus rapidement possible, de récupérer des médailles et d'éviter les araignées tout en conservant ses vies.

## Objectifs du jeu

Le joueur doit :

- Courir et sauter entre différentes plateformes.
- Éviter les obstacles et les araignées ennemies.
- Ramasser des médailles pour augmenter son score.
- Atteindre la ligne d'arrivée avant la fin du temps.
- Conserver ses trois vies.
- Réaliser le meilleur temps possible.

## Concepts utilisés

### 1. Génération procédurale du parcours

La génération procédurale consiste à créer automatiquement des éléments d'un jeu à l'aide d'un algorithme.

Dans Bug Rush, nous prévoyons d'utiliser ce mécanisme pour générer différentes configurations de plateformes et d'obstacles. Chaque nouvelle partie pourra proposer un parcours différent.

L'algorithme devra respecter certaines contraintes, notamment la distance maximale que le criquet peut franchir en sautant, afin que les parcours restent réalisables.

**Emplacement dans le projet :** ...

**Source d'information :** [Red Blob Games — Terrain Generation](https://www.redblobgames.com/maps/terrain-from-noise/)

**Illustration :** ...

### 2. Intelligence artificielle des araignées

L'intelligence artificielle permet aux ennemis d'adapter leur comportement selon la situation.

Dans Bug Rush, les araignées utiliseront une machine à états finis pour gérer plusieurs comportements :

- **Patrouille :** l'araignée se déplace dans une zone définie.
- **Poursuite :** elle détecte le criquet et se dirige vers lui.
- **Attaque :** elle tente de toucher le joueur lorsqu'il est suffisamment proche.
- **Retour :** elle revient à sa position initiale lorsque le joueur s'éloigne.

Ce système permettra de créer des ennemis plus dynamiques et de rendre les courses plus difficiles.

**Emplacement dans le projet :** ...

**Source d'information :** [Game Programming Patterns — State](https://gameprogrammingpatterns.com/state.html)

**Illustration :** ...

## Fonctionnalités prévues

- Déplacement et saut du criquet.
- Parcours de plateforme avec obstacles.
- Génération procédurale du terrain.
- Araignées avec intelligence artificielle.
- Système de vies et de score.
- Chronomètre et classement des meilleurs scores.
- Menu principal et menu Options.
- Musique et effets sonores.
- Écrans de victoire et de défaite.
- Mise en pause et affichage des statistiques de débogage.

## Technologies utilisées

- **Moteur de jeu :** Godot
- **Langage :** GDScript
- **Gestion de versions :** Git et GitHub
- **Plateforme cible :** Windows et Linux (borne arcade)

## Références

- [Documentation officielle de Godot](https://docs.godotengine.org/)
- [Red Blob Games — Terrain from Noise](https://www.redblobgames.com/maps/terrain-from-noise/)
- [Game Programming Patterns — State](https://gameprogrammingpatterns.com/state.html)
