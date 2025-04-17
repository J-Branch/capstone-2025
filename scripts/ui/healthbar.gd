extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar
@export var id = 0

var health = 0 : set = _set_health

func _ready():
	add_to_group("healthbars")

func _set_health(new_health):
	var prev_health = health
	health = min (max_value, new_health)
	value = health
	
	if health <= 0:
		queue_free()
		
	if health < prev_health:
		timer.start()
	else: damage_bar.value = health

func init_health(_health):
	max_value = _health
	health = _health
	value = health
	damage_bar.max_value = health 
	damage_bar.value = health

func _on_timer_timeout() -> void:
	damage_bar.value = health


func _on_sword_fighter_health_changed(current_health: Variant) -> void:
	_set_health(current_health)


func _on_robo_fighter_health_changed(current_health: int) -> void:
	_set_health(current_health)
