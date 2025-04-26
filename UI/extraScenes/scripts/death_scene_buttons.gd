extends Control

@onready var button: Button = $"Button"

signal button_selected()
signal button_hovered()
signal button_dehovered()

func _ready():
	button.modulate = Color(1,1,1,1)

func _on_button_pressed() -> void:
	emit_signal("button_selected")

func _on_button_mouse_entered() -> void:
	button.modulate = Color(1,1,1,0.7)
	emit_signal("button_hovered")


func _on_button_mouse_exited() -> void:
	button.modulate = Color(1,1,1,1)
	emit_signal("button_dehovered")

func set_button_text(new_text: String):
	button.text = new_text
