extends Node2D

func _on_top_area_entered(area):
	area.get_parent().global_position = Vector2(area.get_parent().global_position.x, 650)


func _on_bottom_area_entered(area):
	area.get_parent().global_position = Vector2(area.get_parent().global_position.x, 50)


func _on_right_area_entered(area):
	area.get_parent().global_position = Vector2(100, area.get_parent().global_position.y)


func _on_left_area_entered(area):
	area.get_parent().global_position = Vector2(1200, area.get_parent().global_position.y)
