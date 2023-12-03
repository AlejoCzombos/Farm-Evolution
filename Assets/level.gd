extends Node2D
@export var next_level : PackedScene
@export var objetives : Dictionary = {
	1 : 0,
	2 : 0,
	3 : 0,
	4 : 0
}

var objetives_completed : Dictionary
var actual_objetives : Dictionary

func _ready():
	for key in objetives.keys():
		if objetives[key] == 0:
			objetives.erase(key)
	
	actual_objetives = objetives.duplicate()
	
	_on_evolve_cow(null)
	Signals.onEvolveCow.connect(_on_evolve_cow)
	Signals.createObjetives.emit(objetives.duplicate())

#func _on_evolve_cow(Cow: Node):
#	actual_objetives = objetives.duplicate()
#
#	var childrens = get_children()
#
#	for child in childrens:
#		if child.is_in_group("Cows") and child != Cow:
#
#			if child.actual_level in actual_objetives.keys():
#
#				if actual_objetives.get(child.actual_level) > 1:
#					actual_objetives[child.actual_level] -= 1
#				else:
#					actual_objetives.erase(child.actual_level)
#
#	Signals.updateObjetives.emit(dictionary_to_array(actual_objetives))
#
#	if actual_objetives.is_empty() :
#		move_next_level()

func _on_evolve_cow(Cow: Node):
	var childrens = get_children()
	objetives_completed = {}
	
	for child in childrens:
		if child.is_in_group("Cows") and child != Cow:
			
			if child.actual_level in objetives.keys():
				
				if child.actual_level in objetives_completed.keys():
					if objetives[child.actual_level] > objetives_completed[child.actual_level]:
						objetives_completed[child.actual_level] += 1
				else:
					objetives_completed[child.actual_level] = 1
	
	Signals.updateObjetives.emit(dictionary_to_array(objetives_completed))
	
	if objetives_completed == objetives :
		move_next_level()

func dictionary_to_array(dictionary: Dictionary) -> Array:
	var result_array = []
	for key in dictionary.keys():
		var value = dictionary[key]
		for _i in range(value):
			result_array.append(key)
	return result_array

func move_next_level() -> void:
	get_tree().change_scene_to_packed(next_level)
