extends Node2D
class_name Animal

enum AnimalType {COW, PIG}

@export var actual_level : int = 1
@export var animal_type : AnimalType

@onready var tile_map = $"../../TileMap"
@onready var sprite = $Sprite
@onready var animation_player = $AnimationPlayer
@onready var ray_cast = $RayCast2D
@onready var collision = $CollisionShape2D

var level_name: Array = ["Level1", "Level2", "Level3", "Level4"]
var is_activate: bool = true

func _ready():
	sprite.play(level_name[actual_level - 1])

func move(next_position: Vector2, direction : Vector2, current_tile : Vector2i, current_tile_player: Vector2i):
	ray_cast.enabled = true
	ray_cast.target_position = direction * 16
	ray_cast.force_raycast_update()
	
	if ray_cast.is_colliding():
		var area = ray_cast.get_collider()
		
		if actual_level != area.getLevel() or animal_type != area.getType():
			playError()
			area.playError()
			return false
		
		Signals.movePlayerAndEvolve.emit(area, self, current_tile, current_tile_player) #se mueve una vaca y evoluciona
		
		move_and_diactivate(next_position)
		area.upLevel()
		return true
	else:  #Solo se mueve una vaca
		Signals.movePlayerAndAnimal.emit(self,current_tile, current_tile_player)
	
	var tweenMoviment : Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tweenMoviment.tween_property(self, "position", next_position , 0.2)
	animation_player.play("Move")
	return true

func handler_move(to_pos: Vector2i):
	var next_position: Vector2 = tile_map.map_to_local(to_pos)
	
	if next_position == Vector2.ZERO:
		animation_player.play("Error")
		return
	
	var tweenMoviment : Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tweenMoviment.tween_property(self, "position", next_position , 0.2)
	animation_player.play("Move")
	return true

func toggle_activate():
	is_activate = !is_activate
	collision.disabled = !collision.disabled
	sprite.visible = !sprite.visible
	Signals.onEvolveAnimal.emit()

func playError():
	if randi() % 2 == 0:
		animation_player.play("Error")
	else:
		animation_player.play("Error2")

func move_and_diactivate(next_position : Vector2):
	var tweenMoviment : Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tweenMoviment.tween_property(self, "position", next_position , 0.2)
	animation_player.play("Move")
	tweenMoviment.tween_callback(toggle_activate)

func destroy():
	queue_free()
	await tree_exited #Esperar hsata que se elimine la instancia
	Signals.onEvolveAnimal.emit()

func upLevel():
	if actual_level != 4:
		animation_player.play("Move")
		sprite.play(level_name[actual_level])
		actual_level = actual_level + 1

func downLevel():
	if actual_level != 1:
		actual_level = actual_level - 1
		animation_player.play("Move")
		sprite.play(level_name[actual_level - 1])

func getLevel():
	return actual_level

func setLevel(new_level):
	actual_level = new_level

func getType():
	return animal_type

func getTypeString():
	return AnimalType.keys()[animal_type]
