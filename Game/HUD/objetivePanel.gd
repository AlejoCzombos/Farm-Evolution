extends PanelContainer

@export var cowSprites : Array[Texture]
@export var pigSprites : Array[Texture]
var level : int = 0

func addTexture(animal_type, animal_level):
	match animal_type:
		"COW":
			level = animal_level + 1
			$VBoxContainer/TextureRect.texture = cowSprites[animal_level]
		"PIG": 
			level = animal_level + 1
			$VBoxContainer/TextureRect.texture = pigSprites[animal_level]

func activateCheckBox():
	pass
	#$VBoxContainer/CheckBox.button_pressed = true
func disableCheckBox():
	pass
	#$VBoxContainer/CheckBox.button_pressed = false
