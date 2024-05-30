extends CharacterBody2D
class_name Player

@onready var tile_map = $"../TileMap"
@onready var animation_player = $AnimationPlayer
@onready var ray_cast = $RayCast2D
@onready var animated_sprite = $AnimatedSprite2D

var is_moving : bool = false
var actual_direction = Vector2.RIGHT

func _process(_delta):
	if is_moving:
		return
	
	if Input.is_action_just_pressed("ui_right"):
		move(Vector2.RIGHT)
	if Input.is_action_just_pressed("ui_left"):
		move(Vector2.LEFT)
	if Input.is_action_just_pressed("ui_up"):
		move(Vector2.UP)
	if Input.is_action_just_pressed("ui_down"):
		move(Vector2.DOWN)
	
	if Input.is_key_pressed(KEY_Z):
		Signals.undoMove.emit()

func move(direction: Vector2):
	if direction.x < 0:
		animated_sprite.flip_h = true
	elif direction.x > 0:
		animated_sprite.flip_h = false
	
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	
	var next_position = calculateNextPosition(direction, current_tile)
	
	if next_position == Vector2.ZERO:
		animation_player.play("Error")
		return
	
	ray_cast.target_position = direction * 16
	ray_cast.force_raycast_update()
	
	if ray_cast.is_colliding():
		var area = ray_cast.get_collider()
		
		var current_tile_cow = calculateCurrentTileCow(direction, current_tile)
		var next_position_cow = calculateNextPosition(direction, current_tile_cow)
		
		if next_position_cow == Vector2.ZERO:
			area.playError()
			return
		
		var can_move = area.move(next_position_cow, direction)
		
		if not can_move:
			return
	else:
		Signals.movePlayer.emit(
		self,
		current_tile,
		calculateCurrentTileCow(direction, current_tile)
		)
	
	if not is_moving:
		var tweenMoviment : Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
		tweenMoviment.tween_property(self, "position", next_position , 0.15)
		tweenMoviment.finished.connect(prueba)
		
		animation_player.play("Move")
		is_moving = true

func handler_move(to_pos: Vector2i):
	var next_position: Vector2 = tile_map.map_to_local(to_pos)
	
	if next_position == Vector2.ZERO:
		animation_player.play("Error")
		return
	
	if not is_moving:
		var tweenMoviment : Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
		tweenMoviment.tween_property(self, "position", next_position , 0.15)
		tweenMoviment.finished.connect(prueba)
		
		animation_player.play("Move")
		is_moving = true

func prueba():
	is_moving = false

func calculateNextPosition(direction: Vector2, current_tile: Vector2i) -> Vector2:
	var target_tile: Vector2i = Vector2i(
		current_tile.x + direction.x,
		current_tile.y + direction.y
	)
	
	var tile_data: TileData = tile_map.get_cell_tile_data(2, target_tile)
	
	if not tile_data.get_custom_data("walkable"):
		return Vector2.ZERO
	else:
		return tile_map.map_to_local(target_tile)

func calculateCurrentTileCow(direction: Vector2, current_tile: Vector2i) -> Vector2i:
	var target_tile: Vector2i = Vector2i(
		current_tile.x + direction.x,
		current_tile.y + direction.y
	)
	
	return target_tile

