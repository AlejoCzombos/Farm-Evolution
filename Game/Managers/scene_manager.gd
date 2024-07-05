extends Node

@onready var animator = $AnimationPlayer
var next_scene_file : String

func _ready():
	$ColorRect.visible = true

func change_scene_to(next_scene : String) -> void:
	animator.play("fade-out")
	next_scene_file = next_scene

func change_scene() -> void:
	get_tree().change_scene_to_file(next_scene_file)
	

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade-out":
		change_scene()
