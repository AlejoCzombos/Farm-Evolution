extends CanvasLayer

@export var main_menu_scene : PackedScene
@export var option_scene : PackedScene

func _ready():
	visible = false

func _input(event):
	if event.is_action_pressed("Pause"):
		visible = !visible
		get_tree().paused = !get_tree().paused

func _on_continue_button_pressed():
	visible = !visible
	get_tree().paused = !get_tree().paused


func _on_option_button_pressed():
	print("Options")


func _on_back_to_menu_button_pressed():
	get_tree().paused = !get_tree().paused
	get_tree().change_scene_to_packed(main_menu_scene)
