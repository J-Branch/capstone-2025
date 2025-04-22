extends Node2D

@onready var sword_scene = preload("res://characters/SwordFighter/scenes/SwordFighter.tscn")
@onready var robo_scene = preload("res://characters/RoboFighter/scenes/RoboFighter.tscn")

var spawn_point_1 = Vector2(-400, 250)
var spawn_point_2 = Vector2(400, 250)

func _ready():
	# Instantiate characters
	if Globals.css["char_1"] == "SWORDSMAN":
		var instance1 = sword_scene.instantiate()
		instance1.id = 1
		instance1.position = spawn_point_1
		add_child(instance1)
	else:
		var instance1 = robo_scene.instantiate()
		instance1.id = 1
		instance1.position = spawn_point_1
		add_child(instance1)
	
	if Globals.css["char_2"] == "SWORDSMAN":
		var instance2 = sword_scene.instantiate()
		instance2.id = 2
		instance2.position = spawn_point_2
		add_child(instance2)
		instance2.turn(true)
	else:
		var instance2 = robo_scene.instantiate()
		instance2.id = 2
		instance2.position = spawn_point_2
		add_child(instance2)
		instance2.turn(true)
		
	var characters = get_tree().get_nodes_in_group("fighters")
	var health_bars = get_tree().get_nodes_in_group("healthbars")
	var transform_bars = get_tree().get_nodes_in_group("transformbars")
	
	var char1 = characters[0]
	var char2 = characters[1]
	
	var healthbar1 = health_bars[0]
	var healthbar2 = health_bars[1]
	
	var transformbar1 = transform_bars[0]
	var transformbar2 = transform_bars[1]
	
	# Script for Health Bars
	if char1.id == healthbar1.id:
		char1.health_changed.connect(healthbar1._set_health)
		char2.health_changed.connect(healthbar2._set_health)
	else:
		char1.health_changed.connect(healthbar2._set_health)
		char2.health_changed.connect(healthbar1._set_health)
	
	# Script for Transform Bars
	if char1.id == transformbar1.id:
		char1.transform_changed.connect(transformbar1._set_transform)
		char2.transform_changed.connect(transformbar2._set_transform)
	else:
		char1.transform_changed.connect(transformbar2._set_transform)
		char2.transform_changed.connect(transformbar1._set_transform)
