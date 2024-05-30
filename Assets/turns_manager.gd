extends Node

@onready var tile_map : TileMap = $"../../TileMap"

var move_history: Array = []

enum ActionType { MOVE_PLAYER, EVOLVE_ANIMAL }

func _ready():
	Signals.movePlayer.connect(move_player)
	Signals.movePlayerAndEvolve.connect(move_player_and_evolve)
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
			ActionType.EVOLVE_ANIMAL:
				undo_evolve_animal(data)

func undo_move_player(data: Dictionary):
	var player = data["player"]
	var from_pos = data["from_pos"]
	player.handler_move(from_pos)

func undo_evolve_animal(data: Dictionary):
	var animal = data["animal"]
	animal.level = data["old_level"]

func move_player(player: Player, from_pos: Vector2i, to_pos: Vector2i):
	print(player, from_pos, to_pos)
	record_action(ActionType.MOVE_PLAYER, { "player": player, "from_pos": from_pos, "to_pos": to_pos })

func move_player_and_evolve(animal: Animal):
	var old_level = animal.level
	animal.level += 1
	record_action(ActionType.EVOLVE_ANIMAL, { "animal": animal, "old_level": old_level, "new_level": animal.level })
