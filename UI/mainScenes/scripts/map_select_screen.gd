extends Control

@onready var map_preview: Node2D = $"VBoxContainer/Map Container/Node2D"

var current_index = 0
var current_map_instance = null
var current_scene_instance = null
# map_num used to stop map select from recieving input in game
var map_num = 0

var maps = [
	preload("res://scenes/maps/map1.tscn"),
	preload("res://scenes/maps/map2.tscn"),
	preload("res://scenes/maps/map3.tscn"),
	preload("res://scenes/maps/map4.tscn"),
	preload("res://scenes/maps/map5.tscn"),
	preload("res://scenes/maps/map6.tscn"),
	preload("res://scenes/maps/map7.tscn")
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_map(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_map(index):
	if current_map_instance:
		current_map_instance.queue_free()
		
	current_map_instance = maps[index].instantiate()
	current_map_instance.scale = Vector2(0.6, 0.6)
	map_preview.add_child(current_map_instance)

func _on_previous_button_selected() -> void:
	if map_num == 0:
		current_index = (current_index - 1) % maps.size()
		load_map(current_index)


func _on_next_button_selected() -> void:
	if map_num == 0:
		current_index = (current_index + 1) % maps.size()
		load_map(current_index)


func _on_start_button_selected() -> void:
	if map_num == 0:
		current_map_instance.scale = Vector2(1, 1)
		var map_scene = maps[current_index]
		Globals.current_game_scene["scene"] = map_scene
		current_scene_instance = map_scene.instantiate()
		add_child(current_scene_instance)
		current_scene_instance.emit_signal("game_ready")
		await get_tree().process_frame
		map_num += 1
