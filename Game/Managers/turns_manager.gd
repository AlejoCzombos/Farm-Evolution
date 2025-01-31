extends Node

var move_history: Array = []

enum ActionType { MOVE_PLAYER, MOVE_ANIMAL, EVOLVE_ANIMAL }

func _ready():
	Signals.movePlayer.connect(move_player)
	Signals.movePlayerAndEvolve.connect(move_player_and_evolve)
	Signals.movePlayerAndAnimal.connect(move_player_and_animal)
	Signals.undoMove.connect(undo_last_action)

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
			ActionType.MOVE_ANIMAL:
				undo_move_player_and_animal(data)
			ActionType.EVOLVE_ANIMAL:
				undo_evolve_animal(data)

func undo_move_player(data: Dictionary):
	var from_pos = data["from_pos"]
	Globals.get_current_player().handler_move(from_pos)

func undo_move_player_and_animal(data: Dictionary):
	var animal = data["animal"]
	var from_pos = data["from_pos"]
	var from_pos_player = data["from_pos_player"]
	Globals.get_current_player().handler_move(from_pos_player)
	animal.handler_move(from_pos)

func undo_evolve_animal(data: Dictionary):
	var animal = data["animal"]
	var animal_diactivate = data["animal_diactivate"]
	var from_pos = data["from_pos"]
	var from_pos_player = data["from_pos_player"]
	
	animal.downLevel()
	animal_diactivate.toggle_activate()
	animal_diactivate.handler_move(from_pos)
	Globals.get_current_player().handler_move(from_pos_player)

func move_player(from_pos: Vector2i, to_pos: Vector2i):
	record_action(ActionType.MOVE_PLAYER, { "from_pos": from_pos, "to_pos": to_pos })

func move_player_and_animal(animal: Animal, from_pos_animal: Vector2i, from_pos_player: Vector2i):
	record_action(ActionType.MOVE_ANIMAL, { "animal": animal, "from_pos": from_pos_animal, "from_pos_player": from_pos_player })

func move_player_and_evolve(
	animal: Animal, 
	animal_diactivate: Animal, 
	from_pos_animal: Vector2i,
	from_pos_player: Vector2i
	):
	record_action(ActionType.EVOLVE_ANIMAL, { "animal": animal, "animal_diactivate": animal_diactivate, "from_pos": from_pos_animal, "from_pos_player": from_pos_player})

func print_history():
	for move in move_history:
		if move["type"] != ActionType.MOVE_PLAYER: print(move)
	print("\n")
