extends Panel

@export var cowSprites : Array[Texture]
var level : int = 0

func addTexture(index):
	level = index + 1
	$VBoxContainer/TextureRect.texture = cowSprites[index]

func activateCheckBox():
	$VBoxContainer/CheckBox.button_pressed = true
func disableCheckBox():
	$VBoxContainer/CheckBox.button_pressed = false
