extends CanvasLayer

@export_file("*.tscn") var initial_level_scene : String
@export var option_scene : PackedScene
@onready var scene_manager = $SceneManager

func _on_play_button_pressed():
	scene_manager.change_scene_to(initial_level_scene)


func _on_options_button_pressed():
	print("Options")


func _on_exit_button_pressed():
	get_tree().quit()
