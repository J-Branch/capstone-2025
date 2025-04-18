extends Node2D


func _ready() -> void:
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
