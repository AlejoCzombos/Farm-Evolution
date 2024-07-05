extends CanvasLayer
@export_file("*.tscn") var main_menu_scene : String
@export_file("*.tscn") var option_scene : String

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
	get_tree().change_scene_to_file(main_menu_scene)
