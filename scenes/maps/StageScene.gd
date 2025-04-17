extends Node2D


func _ready() -> void:
	var characters = get_tree().get_nodes_in_group("fighters")
	var health_bars = get_tree().get_nodes_in_group("healthbars")
	
	var char1 = characters[0]
	var char2 = characters[1]
	
	var healthbar1 = health_bars[0]
	var healthbar2 = health_bars[1]
	
	if char1.id == healthbar1.id:
		char1.health_changed.connect(healthbar1._set_health)
		char2.health_changed.connect(healthbar2._set_health)
	else:
		char1.health_changed.connect(healthbar2._set_health)
		char2.health_changed.connect(healthbar1._set_health)
