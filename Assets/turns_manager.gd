extends Node

@onready var tile_map : TileMap = $"../../TileMap"

var turns : Array
var current_turn : Array

var all_tiles : Array[Vector2i]
var used_tiles : Array[Vector2i]
var matrix_size : Vector2i
var min_values_matrix: Vector2i

func _ready():
	all_tiles = tile_map.get_used_cells(2)
	used_tiles = get_used_tiles(all_tiles)
	matrix_size = get_matrix_size(used_tiles)
	

func get_used_tiles(total_tiles : Array[Vector2i]) -> Array[Vector2i]:
	var walkeable_tiles : Array[Vector2i]
	for i in range(all_tiles.size()):
		var tile_data: TileData = tile_map.get_cell_tile_data(2, all_tiles[i])
		
		if not tile_data.get_custom_data("walkable"):
			continue
		
		walkeable_tiles.append(all_tiles[i])
	return walkeable_tiles

func get_matrix_size(walkeable_tiles : Array[Vector2i]) -> Vector2i:
	var min_size : Vector2i = Vector2i(99,99)
	var max_size : Vector2i = Vector2i(-99,-99)
	
	for i in range(used_tiles.size()):
		if walkeable_tiles[i].x < min_size.x: min_size.x = walkeable_tiles[i].x
		if walkeable_tiles[i].y < min_size.y: min_size.y = walkeable_tiles[i].y
		if walkeable_tiles[i].x > max_size.x: max_size.x = walkeable_tiles[i].x
		if walkeable_tiles[i].y > max_size.y: max_size.y = walkeable_tiles[i].y
	
	min_values_matrix = max_size
	return Vector2i(
		(max_size.x - min_size.x) + 1,
		(max_size.y - min_size.y) + 1
	)

func print_matrix(matrix: Array):
	for row in matrix:
		print(row)
