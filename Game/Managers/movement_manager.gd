extends Node

@export var movement_tile: TileMapLayer
@export var move_player_and_animal_together : bool = false

var player: Player
var move_history: Array = []

enum ActionType { MOVE_PLAYER, MOVE_PLAYER_AND_ANIMAL, MOVE_PLAYER_AND_ANIMAL_AND_EVOLVE }

func _ready() -> void:
	Globals.movement_tile = movement_tile
	player = Globals.get_current_player()
	
	Signals.undo_move.connect(undo_last_action)
	Signals.move_player.connect(move_player)

func move_player(player_current_position: Vector2, player_direction: Vector2) -> void:
	var player_current_tile : Vector2i = movement_tile.local_to_map(player_current_position)
	
	var player_target_tile = calculate_next_tile(player_direction, player_current_tile)
	
	if not is_tile_walkeable(player_target_tile):
		player.play_error()
		return
	
	# Se reacomoda y actualiza el raycast
	player.ray_cast.target_position = player_direction * 16
	player.ray_cast.force_raycast_update()
	
	if player.ray_cast.is_colliding():
		# Colisionó con un animal y se tiene que hacer calculos
		move_player_and_animal(player_direction, player_current_tile, player_target_tile)
	else:
		var player_target_position = movement_tile.map_to_local(player_target_tile)
		player.handle_move(player_target_position)
		storage_move_player(player_current_tile)

func move_player_and_animal(direction: Vector2, player_current_tile : Vector2i, player_target_tile: Vector2i) -> void:
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
		var second_animal_target_position = calculate_target_position(animal_target_tile)
		
		Globals.current_camera.shake_camera()
		storage_move_player_and_animal_and_evolve(second_animal, animal, animal_current_tile, player_current_tile)
		
		animal.move_and_diactivate(second_animal_target_position)
		second_animal.up_level()
		if move_player_and_animal_together:
			var player_target_position = calculate_target_position(player_target_tile)
			player.handle_move(player_target_position)
	else:  #Solo se mueve un animal
		storage_move_player_and_animal(animal, animal_current_tile, player_current_tile)
		
		Globals.current_camera.shake_camera()
		var animal_target_position = calculate_target_position(animal_target_tile)
		animal.handle_move(animal_target_position)
		
		if move_player_and_animal_together:
			var player_target_position = calculate_target_position(player_target_tile)
			player.handle_move(player_target_position)

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

func calculate_target_position(target_tile: Vector2i) -> Vector2:
	return movement_tile.map_to_local(target_tile)

func record_action(action_type: ActionType, data: Dictionary):
	move_history.append({ "type": action_type, "data": data })

func undo_last_action():
	if move_history.size() > 0:
		var last_action = move_history.pop_back()
		var action_type = last_action["type"]
		var data = last_action["data"]
		
		match action_type:
			ActionType.MOVE_PLAYER:
				undo_move_player(data)
			ActionType.MOVE_PLAYER_AND_ANIMAL:
				undo_move_player_and_animal(data)
			ActionType.MOVE_PLAYER_AND_ANIMAL_AND_EVOLVE:
				undo_move_player_and_animal_and_evolve(data)

func storage_move_player(from_tile_player: Vector2i):
	record_action(ActionType.MOVE_PLAYER, { "from_tile_player": from_tile_player })

func storage_move_player_and_animal(animal: Animal, from_tile_animal: Vector2i, from_tile_player: Vector2i):
	record_action(ActionType.MOVE_PLAYER_AND_ANIMAL, { "animal": animal, "from_tile_animal": from_tile_animal, "from_tile_player": from_tile_player })

func storage_move_player_and_animal_and_evolve(
	animal: Animal, 
	animal_diactivate: Animal, 
	from_tile_animal: Vector2i,
	from_tile_player: Vector2i
	):
	record_action(ActionType.MOVE_PLAYER_AND_ANIMAL_AND_EVOLVE, 
	{ "animal": animal, 
	"animal_diactivate": animal_diactivate, 
	"from_tile_animal": from_tile_animal, 
	"from_tile_player": from_tile_player})

func undo_move_player(data: Dictionary):
	var from_tile_player = data["from_tile_player"]
	var player_target_position = calculate_target_position(from_tile_player)
	player.handle_move(player_target_position)

func undo_move_player_and_animal(data: Dictionary):
	var animal = data["animal"]
	var from_tile_animal = data["from_tile_animal"]
	var from_tile_player = data["from_tile_player"]
	
	var player_target_position = calculate_target_position(from_tile_player)
	var animal_target_position = calculate_target_position(from_tile_animal)
	
	player.handle_move(player_target_position)
	animal.handle_move(animal_target_position)

func undo_move_player_and_animal_and_evolve(data: Dictionary):
	var animal = data["animal"]
	var animal_diactivate = data["animal_diactivate"]
	var from_tile_animal = data["from_tile_animal"]
	var from_tile_player = data["from_tile_player"]
	
	var player_target_position = calculate_target_position(from_tile_player)
	var animal_target_position = calculate_target_position(from_tile_animal)
	
	animal.down_level()
	animal_diactivate.toggle_activate()
	
	player.handle_move(player_target_position)
	animal.handle_move(animal_target_position)

func print_history():
	for move in move_history:
		if move["type"] != ActionType.MOVE_PLAYER: print(move)
	print("\n")
