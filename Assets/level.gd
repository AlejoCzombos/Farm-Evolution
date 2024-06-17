extends Node2D
@export var next_level : PackedScene
@export var objetives : Dictionary = {
	"COW": {
		1: 0,
		2: 0,
		3: 0,
		4: 0
	},
	"PIG": {
		1: 0,
		2: 0,
		3: 0,
		4: 0
	}
}

@onready var scene_manager = $SceneManager

var objetives_completed : Dictionary
var actual_objetives : Dictionary

func _ready():
	actual_objetives = {}
	for animal_type in objetives.keys():
		actual_objetives[animal_type] = {}
		for key in objetives[animal_type].keys():
			if objetives[animal_type][key] != 0:
				actual_objetives[animal_type][key] = objetives[animal_type][key]
	
	_on_evolve_animal()
	Signals.onEvolveAnimal.connect(_on_evolve_animal)
	Signals.createObjetives.emit(actual_objetives)

func _on_evolve_animal():
	var animals = get_tree().get_nodes_in_group("Animal")
	objetives_completed = { "COW": {}, "PIG": {}}
	
	for animal in animals:
		if not animal.is_activate: 
			continue
		
		var animal_type = animal.getTypeString()
		var animal_level = animal.getLevel()
		
		if animal_level in actual_objetives[animal_type].keys():
			#prints("Esta dentro de los objetivos ", animal_type, animal_level)
			if animal_level in objetives_completed[animal_type].keys():
				#prints("Esta dentro de los objetivos completados", animal_type, animal_level)
				if actual_objetives[animal_type][animal_level] > objetives_completed[animal_type][animal.actual_level]:
					objetives_completed[animal_type][animal_level] += 1
			else:
				objetives_completed[animal_type][animal_level] = 1
	
	Signals.updateObjetives.emit(dictionary_to_array(objetives_completed))
	
	if check_objetives_completed():
		scene_manager.change_scene_to_next_level()

func dictionary_to_array(dictionary: Dictionary) -> Array:
	var result_array = []
	for animal_type in dictionary.keys():
		for key in dictionary[animal_type].keys():
			var value = dictionary[animal_type][key]
			for _i in range(value):
				result_array.append(key)
	return result_array

func check_objetives_completed() -> bool:
	for animal_type in actual_objetives.keys():
		if objetives_completed[animal_type] != actual_objetives[animal_type]:
			return false
	return true
