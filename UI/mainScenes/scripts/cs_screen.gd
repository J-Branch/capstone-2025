extends Control

var id = 1
@export var SWORDSMAN: Texture 
@export var ROBOT: Texture 
var char1_selected = false
var char2_selected = false
@onready var texture_rect_1: TextureRect = $"CSS Sections/Char Preview1/TextureRect1"
@onready var texture_rect_2: TextureRect = $"CSS Sections/Char Preview2/TextureRect2"
@onready var hover_texture_1: TextureRect = $"CSS Sections/Char Preview1/HoverTexture1"
@onready var hover_texture_2: TextureRect = $"CSS Sections/Char Preview2/HoverTexture2"

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://UI/mainScenes/main_menu.tscn")


func _on_character_deselected(character: Variant) -> void:
		# If both characters are selected
		if char1_selected and char2_selected:
			char2_selected = false
		else:
			char1_selected = false


func _on_character_selected(character: Variant) -> void:
	match character:
		'SWORDSMAN':
			if not char1_selected:
				Globals.css["char_1"] = "SWORDSMAN"
				char1_selected = true
				texture_rect_1.texture = SWORDSMAN
				
			## If we have selected both
			elif char1_selected and char2_selected:
				pass
				
				# If we have selected just the first one
			else:
				Globals.css["char_2"] = 'SWORDSMAN'
				char2_selected = true
				texture_rect_2.texture = SWORDSMAN

		'ROBOT':
			# If we have not selected the first character yet
			if not char1_selected:
				Globals.css["char1"] = 'ROBOT'
				char1_selected = true
				texture_rect_1.texture = ROBOT
				
			## If we have selected both
			elif char1_selected and char2_selected:
				pass
				
				# If we have selected just the first one
			else:
				Globals.css["char2"] = 'ROBOT'
				char2_selected = true
				texture_rect_2.texture = ROBOT

func _on_character_hovered(character: Variant) -> void:
	match character:
		'SWORDSMAN':
			# If we have not selected the first character yet
			if not char1_selected:
				hover_texture_1.texture = SWORDSMAN
				
			## If we have selected both
			
			elif char1_selected and char2_selected:
				pass
				# If we have selected just the first one
			else:
				hover_texture_2.texture = SWORDSMAN
		'ROBOT':
			# If we have not selected the first character yet
			if not char1_selected:
				hover_texture_1.texture = ROBOT
				
			## If we have selected both
			
			elif char1_selected and char2_selected:
				pass
				# If we have selected just the first one
			else:
				hover_texture_2.texture = ROBOT


func _on_character_dehovered(character: Variant) -> void:
	match character:
		'SWORDSMAN':
			pass
		'ROBOT':
			# If we have not selected the first character yet
			if char1_selected == false:
				pass
				
			## If we have selected both
			
			elif char1_selected and char2_selected:
				pass
				# If we have selected just the first one
			else:
				pass


func _on_back_button_selected() -> void:
	if char2_selected:
		Globals.css["char2"] = ""
		char2_selected = false
		texture_rect_2.texture = null
		hover_texture_2.texture = null
	else:
		Globals.css["char1"] = ""
		char1_selected = false
		texture_rect_1.texture = null
		hover_texture_1.texture = null
		hover_texture_2.texture = null


func _on_start_button_selected() -> void:
	if char1_selected and char2_selected:
		Globals.current_game_scene["scene"] = "res://UI/mainScenes/Map_select_screen.tscn"
		get_tree().change_scene_to_file("res://UI/mainScenes/Map_select_screen.tscn")
	else: 
		pass
