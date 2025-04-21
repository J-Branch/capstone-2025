@tool
extends Control

@export var id: int
@onready var hover_texture = get_node("Hover Texture")
@onready var full_texture = get_node("Full Texture")
@onready var text = %"Character Name"

signal char_ready(character, id)
signal char_unready(character, id)

@export var SWORDSMAN: Texture 
@export var ROBOT: Texture 

@export var banner_color: Color = Color(1,0,0):
	get:
		return banner_color
	set(value):
		banner_color = value
		$"Bottom Text/ColorRect".color = banner_color

@export var bg_color: Color = Color(1,0,0.006, 0.243):
	get:
		return bg_color
	set(value):
		bg_color = value
		$"Background Color".color = bg_color

func _on_Character_hovered(character, child, id):
	if self.id == id:
		match character:
			'SWORDSMAN':
				character = SWORDSMAN
				hover_texture.set_texture(SWORDSMAN)
				full_texture.set_visible(false)
				full_texture.set_texture(SWORDSMAN)
				text.text = 'SWORDSMAN'
			'ROBOT':
				character = ROBOT
				hover_texture.set_texture(ROBOT)
				full_texture.set_visible(false)
				full_texture.set_texture(ROBOT)
				text.text = 'ROBOT'

func _on_Character_selected(character, child, id):
	if self.id == id:
		match character:
			'SWORDSMAN':
				character = SWORDSMAN
				hover_texture.set_visible(false)
				full_texture.set_visible(true)
				emit_signal("char_ready", "SWORDSMAN", id)
			'ROBOT':
				character = ROBOT
				hover_texture.set_visible(false)
				full_texture.set_visible(true)
				emit_signal("char_ready", "ROBOT", id)

func _on_Character_deselected(character, child, id):
	if self.id == id:
		match character:
			'SWORDSMAN':
				character = SWORDSMAN
				hover_texture.set_visible(true)
				full_texture.set_visible(false)
				emit_signal("char_unready", "SWORDSMAN", id)
			'ROBOT':
				character = ROBOT
				hover_texture.set_visible(true)
				full_texture.set_visible(false)
				emit_signal("char_unready", "ROBOT", id)
