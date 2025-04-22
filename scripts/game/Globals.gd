extends Node

func hitstun(mod, duration):
	Engine.time_scale = mod / 100
	await get_tree().create_timer(duration * Engine.time_scale).timeout
	Engine.time_scale = 1

var css = {
	"char_1": "",
	"char_2": "",
}

var player_1 = {
	"health" : 100,
}

var player_2 = {
	"health" : 100,
}
