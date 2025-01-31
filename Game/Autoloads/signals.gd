extends Node

signal onEvolveAnimal
signal createObjetives
signal updateObjetives

#Almacenar movimientos
signal move_player(player_position: Vector2)
signal move_player_and_animal(current_tile)

signal movePlayerAndEvolve
signal undoMove
