extends CharacterBody2D
class_name Player

@onready var animation_player = $AnimationPlayer
@onready var ray_cast = $RayCast2D
@onready var animated_sprite = $AnimatedSprite2D

var is_moving : bool = false
var actual_direction = Vector2.RIGHT

func _ready():
	Globals.set_current_player(self)

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
	
	if Input.is_action_just_pressed("ui_undo"):
		Signals.undoMove.emit()

func move(direction: Vector2):
	if direction.x < 0:
		animated_sprite.flip_h = true
	elif direction.x > 0:
		animated_sprite.flip_h = false
	
	Signals.move_player.emit(global_position, direction)

func handle_move(target_position: Vector2):
	if target_position == Vector2.ZERO:
		play_error()
		return
	
	if not is_moving:
		var tweenMoviment : Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
		tweenMoviment.tween_property(self, "position", target_position , 0.15)
		tweenMoviment.finished.connect(toggle_is_moving)
		
		#animation_player.play("Move")
		is_moving = true

func play_error() -> void:
	animation_player.play("Error")

func toggle_is_moving() -> void:
	is_moving = false
