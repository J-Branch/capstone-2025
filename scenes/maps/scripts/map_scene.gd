extends Node2D

@onready var sword_scene = preload("res://characters/SwordFighter/scenes/SwordFighter.tscn")
@onready var robo_scene = preload("res://characters/RoboFighter/scenes/RoboFighter.tscn")
@onready var healthbar1 = preload("res://UI/extraScenes/health_bar.tscn")
@onready var healthbar2 = preload("res://UI/extraScenes/health_bar.tscn")
@onready var transformbar1 = preload("res://UI/extraScenes/transform_bar.tscn")
@onready var transformbar2 = preload("res://UI/extraScenes/transform_bar.tscn")
@onready var hud_layer: CanvasLayer = $HUDLayer

var spawn_point_1 = Vector2(-400, 250)
var spawn_point_2 = Vector2(400, 250)
signal game_ready

var pause_menu
var death_menu

func _process(delta):
	if Globals.player_1["health"] <= 0:
		show_death_scene("Player 2")
	if Globals.player_2["health"] <= 0:
		show_death_scene("Player 1")

func show_death_scene(winner_name: String):
	death_menu.get_node("VBoxContainer/LabelControl/WinnerLabel").text = "%s Wins!" % winner_name
	death_menu.show()
	death_menu.set_process_input(true)
	# Clears everything from the scene
	for f in get_tree().get_nodes_in_group("fighters"):
		f.queue_free()
	for h in get_tree().get_nodes_in_group("healthbars"):
		h.queue_free()
	for t in get_tree().get_nodes_in_group("transformbars"):
		t.queue_free()
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			_resume_game()
		else:
			_pause_game()

# Code for when resume is pressed
func _resume_game():
	pause_menu.hide() # Hide the pause menu
	pause_menu.set_process_input(false) # Don't allow it to recieve input
	get_tree().paused = false # Unpause the game

# Code when pause menu is up
func _pause_game():
	pause_menu.show() # Show the pause menu
	pause_menu.set_process_input(true) # Allow it to recieve input
	get_tree().paused = true # Pause the game

func _ready():
	pause_menu = preload("res://UI/mainScenes/pause_menu.tscn").instantiate()
	pause_menu.name = "PauseMenu"
	add_child(pause_menu)
	pause_menu.hide()
	pause_menu.set_process_input(false)
	pause_menu.resume_requested.connect(_on_resume_game)
	
	death_menu = preload("res://UI/mainScenes/Death_menu.tscn").instantiate()
	add_child(death_menu)
	death_menu.hide()
	death_menu.set_process_input(false)
	death_menu.rematch_pressed.connect(restart_game)
	
	connect("game_ready", Callable(self, "_on_start_gameplay"))

func _on_resume_game():
	pause_menu.hide()
	get_tree().paused = false
	pause_menu.set_process_input(false)

func _on_start_gameplay():
	# Instantiate characters
	if Globals.css["char_1"] == "SWORDSMAN":
		var instance1 = sword_scene.instantiate()
		instance1.name = "Player1"
		instance1.id = 1
		instance1.position = spawn_point_1
		add_child(instance1)

	else:
		var instance1 = robo_scene.instantiate()
		instance1.name = "Player1"
		instance1.id = 1
		instance1.position = spawn_point_1
		add_child(instance1)
	
	if Globals.css["char_2"] == "SWORDSMAN":
		var instance2 = sword_scene.instantiate()
		instance2.name = "Player2"
		instance2.id = 2
		instance2.position = spawn_point_2
		add_child(instance2)
		instance2.turn(true)
	else:
		var instance2 = robo_scene.instantiate()
		instance2.name = "Player2"
		instance2.id = 2
		instance2.position = spawn_point_2
		add_child(instance2)
		instance2.turn(true)
		
	# Instantiate Health & Transform Bars
	var hb1 = healthbar1.instantiate()
	hb1.name = "Healthbar1"
	hud_layer.add_child(hb1)
	hb1.position = Vector2(41, 20)
	hb1.id = 1
	var hb2 = healthbar2.instantiate()
	hb2.name = "Healthbar2"
	hud_layer.add_child(hb2)
	hb2.position = Vector2(903, 20)
	hb2.id = 2
	var tb1 = transformbar1.instantiate()
	tb1.name = "Transformbar1"
	hud_layer.add_child(tb1)
	tb1.position = Vector2(41, 70)
	tb1.id = 1
	var tb2 = transformbar2.instantiate()
	tb2.name = "Transformbar2"
	hud_layer.add_child(tb2)
	tb2.position = Vector2(903, 70)
	tb2.id = 2
		
		
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

func restart_game():
	# Reset Health
	Globals.player_1["health"] = 100
	Globals.player_2["health"] = 100
	
	# Hide Death Menu
	death_menu.hide()
	death_menu.set_process_input(false)
	
	# Re-initialize game
	_on_start_gameplay()
	
	
