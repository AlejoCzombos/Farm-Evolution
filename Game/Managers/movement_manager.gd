extends Node

@export var movement_tile: TileMapLayer
var player: Player

func _ready() -> void:
	Globals.movement_tile = movement_tile
	player = Globals.get_current_player()
	Signals.move_player.connect(move_player)


func move_player(player_position: Vector2, player_direction: Vector2) -> void:
	var player_current_tile : Vector2i = movement_tile.local_to_map(player_position)
	
	var player_target_tile = calculate_next_tile(player_direction, player_current_tile)
	
	if not is_tile_walkeable(player_target_tile):
		player.play_error()
		return
	
	# Se reacomoda y actualiza el raycast
	player.ray_cast.target_position = player_direction * 16
	player.ray_cast.force_raycast_update()
	
	if player.ray_cast.is_colliding():
		# Colisionó con un animal y se tiene que hacer calculos
		move_player_and_animal(player_direction, player_target_tile)
	else:
		var player_target_position = movement_tile.map_to_local(player_target_tile)
		player.handle_move(player_target_position)

func move_player_and_animal(direction: Vector2, player_target_tile: Vector2i) -> void:
	var animal : Animal = player.ray_cast.get_collider()
	
	var animal_current_tile = player_target_tile
	var animal_target_tile = calculate_next_tile(direction, animal_current_tile)
	
	if not is_tile_walkeable(animal_target_tile):
		animal.play_error()
		return
	
	# Se reacomoda y actualiza el raycast del animal que "mueve" el player
	animal.ray_cast.target_position = direction * 16
	animal.ray_cast.force_raycast_update()
	
	if animal.ray_cast.is_colliding():
		# Colisionó con un otro animal y se tiene que comprobar si puede moverse o si tiene que evolucionar
		var second_animal : Animal = animal.ray_cast.get_collider()
		
		if animal.get_level() != second_animal.get_level() or animal.get_type() != second_animal.get_type():
			animal.play_error()
			second_animal.play_error()
			return
		
		#Signals.movePlayerAndEvolve.emit(area, self, current_tile, current_tile_player) #se mueve una vaca y evoluciona
		var second_animal_target_position = movement_tile.map_to_local(animal_target_tile)
		
		animal.move_and_diactivate(second_animal_target_position)
		second_animal.up_level()
	else:  #Solo se mueve un animal
		#Signals.movePlayerAndAnimal.emit(self,current_tile, current_tile_player)
		var animal_target_position = movement_tile.map_to_local(animal_target_tile)
		animal.handle_move(animal_target_position)

func is_tile_walkeable(target_tile) -> bool:
	var tile_data : TileData = movement_tile.get_cell_tile_data(target_tile)
	if tile_data:
		return tile_data.get_custom_data("walkeable")
	else:
		return 0

func calculate_next_tile(direction: Vector2, current_tile: Vector2i) -> Vector2i:
	var target_tile: Vector2i = Vector2i(
		current_tile.x + direction.x,
		current_tile.y + direction.y
	)
	
	return target_tile
