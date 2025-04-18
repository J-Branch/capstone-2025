extends ProgressBar

@onready var timer = $Timer
@onready var decay_bar = $DecayBar
@export var id = 0

var transform = 0 : set = _set_transform

func _ready():
	add_to_group("transformbars")

func _set_transform(new_transform):
	var prev_transform = transform
	transform = min (max_value, new_transform)
	value = transform
	
	if transform < prev_transform:
		timer.start()
	else: decay_bar.value = transform

func init_transform(_transform):
	max_value = _transform
	transform = _transform
	value = transform
	decay_bar.max_value = transform 
	decay_bar.value = transform

func _on_timer_timeout() -> void:
	decay_bar.value = transform


func _on_sword_fighter_health_changed(current_transform: Variant) -> void:
	_set_transform(current_transform)


func _on_robo_fighter_health_changed(current_transform: int) -> void:
	_set_transform(current_transform)
