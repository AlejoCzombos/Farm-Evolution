extends CanvasLayer

@export var objective_panel : PackedScene

@onready var objetives_panel_container = $ObjetivesContainer/ObjetivesPanelContainer
@onready var animation_player = $AnimationPlayer

var objetives_panels : Array = []

func _ready() -> void:
	Signals.createObjetives.connect(create_objetives)
	Signals.updateObjetives.connect(update_objetives)

func create_objetives(requeriments : Dictionary) -> void:
	for key in requeriments.keys():
		for i in range(requeriments[key]): 
			var scene = objective_panel.instantiate()
			scene.addTexture(key - 1)
			objetives_panels.append(scene)
			objetives_panel_container.add_child(scene)

func update_objetives(requeriments : Array) -> void:
	var requeriment_copy = requeriments.duplicate()
	for objective in objetives_panels:
		
		if requeriment_copy.find(objective.level) != -1:
			
			requeriment_copy.erase(objective.level)
			objective.activateCheckBox() 
		else:
			
			objective.disableCheckBox()
