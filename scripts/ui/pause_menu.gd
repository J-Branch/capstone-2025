extends CanvasLayer

@onready var selector_one = $menuBox/bottom/VBoxContainer/option1/HBoxContainer/Selector
@onready var selector_two = $menuBox/bottom/VBoxContainer/option2/HBoxContainer/Selector
@onready var selector_three = $menuBox/bottom/VBoxContainer/option3/HBoxContainer/Selector
@onready var selector_four = $menuBox/bottom/VBoxContainer/option4/HBoxContainer/Selector

var current_selection = 0

signal resume_requested
signal rematch_requested

func _ready():
	set_current_selection(0)

func _process(delta):
	if Input.is_action_just_pressed("ui_down") and current_selection < 3:
		current_selection += 1 
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_up") and current_selection > 0: 
		current_selection -= 1 
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_accept"):
		handle_selection(current_selection)

func handle_selection(_current_selection): 
	if _current_selection == 0:
		emit_signal("resume_requested")
	# Rematch
	# NOT DOING REMATCH
	elif _current_selection == 1: 
		pass
	# Player Select
	elif _current_selection == 2:
		# Reset globals
		Globals.css["char_1"] = ""
		Globals.css["char_2"] = ""
		get_tree().paused = false
		
		get_tree().change_scene_to_file("res://UI/mainScenes/CS_screen.tscn")
	## set up when finished player select scene
	elif _current_selection == 3: 
		get_tree().change_scene_to_file("res://UI/mainScenes/main_menu.tscn")

func set_current_selection(_current_selection): 
	selector_one.text = ""
	selector_two.text = ""
	selector_three.text = ""
	selector_four.text = ""
	if _current_selection == 0: 
		selector_one.text = ">"
	elif _current_selection == 1:
		selector_two.text = ">"
	elif _current_selection == 2:
		selector_three.text = ">"
	elif _current_selection == 3:
		selector_four.text = ">"
