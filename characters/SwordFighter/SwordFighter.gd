extends CharacterBody2D

var dash_duration = 25

@export var air_jump_max = 1
var air_jump_num = air_jump_max

@onready var states = $State

#Onready variables
@onready var GroundL = $'Raycasts/GroundL'
@onready var GroundR = $'Raycasts/GroundR'

@onready var anim = $Sprite/AnimationPlayer

# Air variables
var landing_frames = 0
var lag_frames = 0

# Hitboxes 
@export var hitbox: PackedScene
var selfState

const RUNSPEED = 300
# DONT KNOW IF WE ARE DOING WALK SPEED YET
const DASHSPEED = 375
const AIR_DASHSPEED = 450
const GRAVITY = 1750
const JUMPFORCE = 1000
const DOUBLEJUMPFORCE = 1000
const MAXAIRSPEED = 300
const AIR_ACCEL = 25
const FALLSPEED = 10
const FALLINGSPEED = 500
const TRACTION = 40

var dir

var frame = 0
func updateframes(delta):
	frame += 1

func create_hitbox(width, height, damage, angle, base_kb, kb_scaling, duration, type, points, angle_flipper, hitlag=1):
	var hitbox_instance = hitbox.instance()
	self.add_child(hitbox_instance)
	# Rotates the points 
	if dir: # looking left
		var flip_x_points = Vector2(-points.x, points.y)
		hitbox_instance.set_parameters(width, height, damage, -angle+180, base_kb, kb_scaling, duration, type, points, angle_flipper, hitlag)
	else: # looking right
		hitbox_instance.set_parameters(width, height, damage, angle, base_kb, kb_scaling, duration, type, points, angle_flipper, hitlag)
	return hitbox_instance

func turn(direction):
	$Sprite.set_flip_h(direction)
	dir = direction
	
func _frame():
	frame = 0

func play_animation(animation_name):
	anim.play(animation_name)

func reset_jump():
	air_jump_num = air_jump_max

func _ready():
	pass

func _physics_process(delta: float) -> void:
	selfState = states.text
	pass

# Ground Attacks
func B_DOWN():
	if frame == 8:
		create_hitbox(20,20,50, 0, 0, 0, 5, 0, Vector2(-16.5,-30.5), 0, 0)
