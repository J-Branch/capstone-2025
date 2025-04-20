extends Control

@onready var anim = %ReadyToFightBanner/AnimationPlayer
@onready var canvas = %ReadyToFightBanner
var selected = true

var start = {
	"char_1": "",
	"char_2": "",
}

func _process(delta):
	Globals.css["char_1"] = start["char_1"]
	Globals.css["char_2"] = start["char_2"]

func readytofight():
	if start["char_1"] and start["char_2"] != "":
		selected = true
		if selected == true:
			canvas.visible = true
			anim.play('Ready')
			selected = false
	else:
		if selected == false:
			anim.play("Not Ready")
		selected = true

func _on_PLAYER_1_char_ready(character, id):
	start["char_1"] = character
	print(start["char_1"])
	readytofight()

func _on_PLAYER_2_char_ready(character, id):
	start["char_2"] = character
	print(start["char_2"])
	readytofight()

func _on_PLAYER_1_char_unready(character, id):
	start["char_1"] = ""
	readytofight()

func _on_PLAYER_2_char_unready(character, id):
	start["char_2"] = ""
	readytofight()
