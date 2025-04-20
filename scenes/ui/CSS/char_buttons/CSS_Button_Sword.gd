extends TextureButton

@export var character:String = "Swordsman"
var id
@export var normal_texture: Texture
@export var pressed_texture: Texture 
@onready var Detector = get_node("CharacterArea")

signal character_selected(character, child, id)
signal character_deselected(chracter, child, id)

signal character_hovered(character, child, id)
signal character_dehovered(character, child, id)

func _on_Character_button_down():
	set_texture_normal(pressed_texture)
	#set_modulate(Color(1,1,1,1,1,1,1))
	emit_signal("character_selected", character, self, id)

func _on_Character_button_up():
	set_texture_normal(normal_texture)
	set_modulate(Color(1,1,1,1))
	emit_signal("character_deselected", character, self, id)

func _on_Character_mouse_entered():
	emit_signal("character_hovered", character, self, id)

func _on_Character_mouse_exited():
	emit_signal("character_hovered", character, self, id)

func _on_Area2D_area_entered(area):
	if area.name == "Coin Area":
		self.id = area.get_parent().id
		emit_signal("Character_hovered", character, self, id)
		if area.get_parent().picked == false:
			print("working")
			emit_signal("button_down")

func _on_Area2D_area_exited(area):
	if area.name == "Coin Area":
		self.id = area.get_parent().id
		if area.get_parent().picked == true:
			emit_signal("button_up")
