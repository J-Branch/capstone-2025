extends TextureRect

@onready var button: Button = $Control/Button

@onready var color_rect: ColorRect = $Background
@export var character:String = "SWORDSMAN"
var id
var hover_color = Color(1, 0, 0, 0.8)
var normal_color = Color("#ff4f5154")

signal character_selected(character)

signal character_hovered(character)
signal character_dehovered(character)

func _ready():
	button.modulate = Color(1,1,1,0)

func _on_button_pressed() -> void:
	emit_signal("character_selected", character)

func _on_button_mouse_entered() -> void:
	color_rect.color = hover_color
	emit_signal("character_hovered", character)

func _on_button_mouse_exited() -> void:
	color_rect.color = normal_color
	emit_signal("character_dehovered", character)
