extends Node2D
class_name Animal

enum AnimalType {COW, PIG}

@export var actual_level : int = 1
@export var animal_type : AnimalType

@onready var sprite = $Sprite
@onready var animation_player = $AnimationPlayer
@onready var ray_cast = $RayCast2D
@onready var collision = $CollisionShape2D
@onready var moveAudio : AudioStreamPlayer2D = $MoveAudio
@onready var errorAudio : AudioStreamPlayer2D = $ErrorAudio

var level_name: Array = ["idle_level_1", "idle_level_2", "idle_level_3", "idle_level_4"]
var is_activate: bool = true

func _ready():
	sprite.play(level_name[actual_level - 1])

	#test
	Signals.print_cow_current_tile.connect(print_current_tile)

func print_current_tile() -> void:
	print("Current tile cow ", self , " : ", Globals.movement_tile.local_to_map(global_position))

func toggle_activate():
	is_activate = !is_activate
	collision.disabled = !collision.disabled
	sprite.visible = !sprite.visible
	Signals.onEvolveAnimal.emit()

func play_error():
	if randi() % 2 == 0:
		animation_player.play("Error")
	else:
		animation_player.play("Error2")

func handle_move(target_position: Vector2):
	if target_position == Vector2.ZERO:
		animation_player.play("Error")
		return
	
	moveAudio.playing = true
	var tweenMoviment : Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tweenMoviment.tween_property(self, "position", target_position , 0.2)
	animation_player.play("Move")
	return true

func move_and_diactivate(next_position : Vector2):
	moveAudio.playing = true
	var tweenMoviment : Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tweenMoviment.tween_property(self, "position", next_position , 0.2)
	animation_player.play("Move")
	tweenMoviment.tween_callback(toggle_activate)

func destroy():
	queue_free()
	await tree_exited #Esperar hsata que se elimine la instancia
	Signals.onEvolveAnimal.emit()

func up_level():
	if actual_level != 4:
		animation_player.play("Move")
		sprite.play(level_name[actual_level])
		actual_level = actual_level + 1

func down_level():
	if actual_level != 1:
		actual_level = actual_level - 1
		animation_player.play("Move")
		sprite.play(level_name[actual_level - 1])

func get_level():
	return actual_level

func set_level(new_level):
	actual_level = new_level

func get_type():
	return animal_type

func get_type_string():
	return AnimalType.keys()[animal_type]
