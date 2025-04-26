extends Control

signal rematch_pressed()

func _ready():
	var rematch_button = get_node("VBoxContainer/Control/HBoxContainer/Control2/VBoxContainer/RematchButton")
	rematch_button.set_button_text("Rematch")
	
	var player_select_button = get_node("VBoxContainer/Control/HBoxContainer/Control2/VBoxContainer/PlayerSelectButton")
	player_select_button.set_button_text("Player Select")
	
	var main_menu_button = get_node("VBoxContainer/Control/HBoxContainer/Control2/VBoxContainer/MainMenuButton")
	main_menu_button.set_button_text("Main Menu")
	

func _on_rematch_button_selected() -> void:
	emit_signal("rematch_pressed")

func _on_player_select_button_selected() -> void:
	# Reset globals
	Globals.css["char_1"] = ""
	Globals.css["char_2"] = ""
	Globals.player_1["health"] = 100
	Globals.player_2["health"] = 100
	get_tree().paused = false
	
	get_tree().change_scene_to_file("res://UI/mainScenes/CS_screen.tscn")


func _on_main_menu_button_selected() -> void:
	# Reset globals
	Globals.css["char_1"] = ""
	Globals.css["char_2"] = ""
	Globals.player_1["health"] = 100
	Globals.player_2["health"] = 100
	get_tree().paused = false
	
	get_tree().change_scene_to_file("res://UI/mainScenes/main_menu.tscn")
