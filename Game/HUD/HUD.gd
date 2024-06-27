extends CanvasLayer

@export var objective_panel : PackedScene

@onready var objetives_panel_container = $ObjetivesContainer/CenterContainer/ObjetivesPanelContainer
@onready var animation_player = $AnimationPlayer
@onready var offset_objetives = $OffsetObjetives

var objetives_panels : Array = []

func _ready() -> void:
	Signals.createObjetives.connect(create_objetives)
	Signals.updateObjetives.connect(update_objetives)

func create_objetives(requeriments : Dictionary) -> void:
	#Se recorre cada animal, luego cada nivel y luego se itera una vez por cantidad para instanciar objetive_panels
	for animal_type in requeriments.keys():
		for animal_level in requeriments[animal_type].keys(): 
			for i in range(requeriments[animal_type][animal_level]):
				var scene = objective_panel.instantiate()
				scene.addTexture(animal_type ,animal_level - 1)
				objetives_panels.append(scene)
				objetives_panel_container.add_child(scene)

func update_objetives(requeriments : Array) -> void:
	var requeriment_copy = requeriments.duplicate()
	for objective in objetives_panels:
		if requeriment_copy.find(objective.level) != -1:
			requeriment_copy.erase(objective.level)
			objective.activateCheckBox() 
			#open_objectives()
		else:
			objective.disableCheckBox()

func open_objectives() -> void:
	if not animation_player.is_playing():
		animation_player.play("open")
		offset_objetives.start()

func _on_offset_objetives_timeout():
	animation_player.play_backwards("open")
