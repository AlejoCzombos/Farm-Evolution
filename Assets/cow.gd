extends Area2D

@export var actual_level : int = 1

@onready var tile_map = $"../TileMap"
@onready var sprite = $Sprite
@onready var animation_player = $AnimationPlayer
@onready var ray_cast = $RayCast2D

var level_name: Array = ["Level1", "Level2", "Level3", "Level4"]  

func _ready():
	sprite.play(level_name[actual_level - 1])

func upLevel():
	if actual_level != 4:
		animation_player.play("Move")
		sprite.play(level_name[actual_level])
		actual_level = actual_level + 1

func move(next_position: Vector2, direction : Vector2):
	
	ray_cast.enabled = true
	ray_cast.target_position = direction * 16
	ray_cast.force_raycast_update()
	
	if ray_cast.is_colliding():
		var area = ray_cast.get_collider()
		
		if actual_level != area.getLevel():
			playError()
			area.playError()
			return false
		
		moveAndDestroy(next_position)
		area.upLevel()
		return true
	
	var tweenMoviment : Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tweenMoviment.tween_property(self, "position", next_position , 0.2)
	animation_player.play("Move")
	return true

func playError():
	if randi() % 2 == 0:
		animation_player.play("Error")
	else:
		animation_player.play("Error2")

func moveAndDestroy(next_position : Vector2):
	var tweenMoviment : Tween = create_tween().set_ease(Tween.EASE_IN)
	tweenMoviment.tween_property(self, "position", next_position , 0.2)
	animation_player.play("Move")
	tweenMoviment.tween_callback(destroy)

func destroy():
	queue_free()
	Signals.onEvolveCow.emit(self)

func getLevel():
	return actual_level
