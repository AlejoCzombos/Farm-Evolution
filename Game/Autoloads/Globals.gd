extends Node
 
var movement_tile : TileMapLayer = null
var current_camera: Camera2D = null

var current_player : Player = null :
	set = set_current_player,
	get = get_current_player

func set_current_player(player:Player) -> void:
	current_player = player

func get_current_player() -> Player:
	return current_player
