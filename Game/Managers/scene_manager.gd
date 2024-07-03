extends Node

@export var next_level : PackedScene

@onready var animator = $AnimationPlayer

func _ready():
	$ColorRect.visible = true

func change_scene_to_next_level() -> void:
	animator.play("fade-out")

func change_scene() -> void:
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(next_level)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade-out":
		change_scene()
