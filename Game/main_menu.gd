extends CanvasLayer

@export var initial_level_scene : PackedScene
@export var option_scene : PackedScene

func _on_play_button_pressed():
	get_tree().change_scene_to_packed(initial_level_scene)


func _on_options_button_pressed():
	print("Options")


func _on_exit_button_pressed():
	get_tree().quit()
