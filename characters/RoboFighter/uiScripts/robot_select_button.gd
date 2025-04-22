extends TextureRect

@onready var button: Button = $"Button Control/Button"

@onready var color_rect: ColorRect = $Background
@export var character:String = "ROBOT"
var id
var hover_color = Color(0, 0, 1, 0.8)
var normal_color = Color("#438eff67")

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
