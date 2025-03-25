extends Area2D

var parent = get_parent()
var width = 300
var height = 400
var damage = 50
var angle = 90
var base_kb = 100
var kb_scaling = 2
var duration = 1500
var hitlag_modifier = 1
var type = 'normal'
var angle_flipper = 0
@onready var hitbox = get_node("Hitbox_Shape")
@onready var parentState = get_parent().selfState
var knockbackVal
var framez
var player_list = []

func set_parameters(w,h,d,a,b_kb,kb_s,dur,t,p,af,hit,parent=get_parent()):
	self.position = Vector2(0,0)
	player_list.append(parent)
	player_list.append(self)
	width = w
	height = h
	damage = d
	angle = a
	base_kb = b_kb
	kb_scaling = kb_s
	duration = dur
	type = t
	self.position = p
	hitlag_modifier = hit
	angle_flipper = af
	# pdate_extents()
	# connect("area_entered", self, "Hitbox_Collide")
	set_physics_process(true)





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
