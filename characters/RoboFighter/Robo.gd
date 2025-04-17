extends CharacterBody2D

@export var id: int

var dash_duration = 25

@export var air_jump_max = 1
var air_jump_num = air_jump_max
var air_dash_max = 1
var air_dash_num = air_dash_max

#Onready variables
@onready var GroundL = $'Raycasts/GroundL'
@onready var GroundR = $'Raycasts/GroundR'
@onready var states = $State
@onready var anim = $Sprite/AnimationPlayer

# Air variables
var landing_frames = 0
var lag_frames = 0

# Hitboxes 
@export var hitbox: PackedScene
var selfState

# Attributes
@export var health = 100
@export var weight = 100
var freezeframes = 0

# Knockback
var hdecay
var vdecay
var knockback
var hitstun
var connected:bool

# Temporary Variables
var hit_pause = 0
var hit_pause_dur = 0
var temp_pos = Vector2(0,0)
var temp_vel = Vector2(0,0)

const RUNSPEED = 600
# DONT KNOW IF WE ARE DOING WALK SPEED YET
const DASHSPEED = 600
const AIR_DASHSPEED = 700
const GRAVITY = 1750
const JUMPFORCE = 700
const DOUBLEJUMPFORCE = 600
const MAXAIRSPEED = 500
const AIR_ACCEL = 25
const FALLSPEED = 25
const FALLINGSPEED = 500
const TRACTION = 55

var dir

var frame = 0
func updateframes(delta):
	frame += floor(delta * 60)
	if freezeframes > 0:
		freezeframes -= floor(delta * 60)
	freezeframes = clamp(freezeframes, 0, freezeframes)

func create_hitbox(width, height, damage, angle, base_kb, kb_scaling, duration, type, points, angle_flipper, hitlag=1):
	var hitbox_instance = hitbox.instantiate()
	self.add_child(hitbox_instance)
	# Rotates the points 
	if dir: # looking left
		var flip_x_points = Vector2(-points.x, points.y)
		hitbox_instance.set_parameters(width, height, damage, -angle+180, base_kb, kb_scaling, duration, type, flip_x_points, angle_flipper, hitlag)
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

func reset_dash():
	air_dash_num = air_dash_max

func _ready():
	pass

func _physics_process(delta: float) -> void:
	selfState = states.text
	pass

func _hit_pause(delta):
	if hit_pause < hit_pause_dur:
		self.position = temp_pos
		hit_pause += floor((1 * delta) * 60)
	else:
		if temp_vel != Vector2(0,0):
			self.velocity.x = temp_vel.x
			self.velocity.y = temp_vel.y
			temp_vel = Vector2(0,0)
		hit_pause_dur = 0
		hit_pause = 0

# Ground Attacks
func B_DOWN():
	if frame == 5:
		create_hitbox(39,23,8, 75, 3, 100, 6, 'normal', Vector2(34,20.5), 0, 1)
	if frame == 12:
		create_hitbox(44.5,30,8, 75, 3, 100, 8, 'normal', Vector2(36.75,17), 0, 1)
	if frame >= 20:
		return true
		
func B_SIDE():
	if frame == 4:
		create_hitbox(21.25,24,8, 60, 3, 120, 20, 'normal', Vector2(16,12), 0, 1)
	if frame >= 24:
		return true

func B_NEUTRAL():
	if frame == 6:
		create_hitbox(27,24,8, 0, 3, 100, 2, 'normal', Vector2(27,-4), 0, 1)
	if frame == 8:
		create_hitbox(37.5,34,8, 0, 3, 100, 2, 'normal', Vector2(32.25,-3), 0, 1)
	if frame == 10:
		create_hitbox(50.5,39,8, 0, 3, 100, 8, 'normal', Vector2(38.75,-4.5), 0, 1)
	if frame >= 20:
		return true

# Air Attacks
func A_DOWN():
	if frame == 11:
		create_hitbox(18,32.5,8, 270, 3, 100, 9, 'normal', Vector2(0,48.75), 0, 1)
	if frame == 20:
		return true

func A_SIDE():
	if frame == 1:
		create_hitbox(39,12,8, 0, 3, 100, 11, 'normal', Vector2(47.5,11), 0, 1)
	if frame >= 12:
		return true

func A_NEUTRAL():
	if frame == 10:
		create_hitbox(64,26,8, 0, 3, 110, 12, 'normal', Vector2(0,14), 0, 1)
	if frame >= 22:
		return true
	
# TRANSFORMED ATTACKS

# Ground Attacks
func T_B_DOWN():
	if frame == 10:
		create_hitbox(52.25,28.5,8, 80, 3, 100, 3, 'normal', Vector2(36.875,18.25), 0, 1)
	if frame == 13:
		create_hitbox(52.25,37.5,8, 80, 3, 100, 7, 'normal', Vector2(36.875,13.75), 0, 1)
	if frame >= 20:
		return true
	
func T_B_SIDE():
	if frame == 6:
		create_hitbox(46.25,42,8, 60, 3, 110, 10, 'normal', Vector2(33.875,13), 0, 1)
	if frame >= 16:
		return true

func T_B_NEUTRAL():
	if frame == 4:
		create_hitbox(41.125,39,8, 40, 3, 60, 2, 'normal', Vector2(29.563,7.5), 0, 1)
	if frame == 6:
		create_hitbox(22.563,24.5,8, 40, 3, 60, 2, 'normal', Vector2(38,9), 0, 1)
	if frame == 8:
		create_hitbox(33,40,8, 40, 3, 60, 8, 'normal', Vector2(34.5,11), 0, 1)
	if frame >= 16:
		return true

# Air Attacks
func T_A_DOWN():
	if frame == 11:
		create_hitbox(43.5,40,8, 270, 3, 115, 9, 'normal', Vector2(-2.75,40), 0, 1)
	if frame >= 20:
		return true

func T_A_SIDE():
	if frame == 4:
		create_hitbox(33.75,32,8, 15, 3, 70, 2, 'normal', Vector2(14,18), 0, 1)
	if frame == 6:
		create_hitbox(39.875,39,8, 15, 3, 70, 2, 'normal', Vector2(22.938,19.5), 0, 1)
	if frame == 8:
		create_hitbox(44.938,43.5,8, 15, 3, 70, 8, 'normal', Vector2(25.531,23.75), 0, 1)
	if frame >= 16:
		return true

func T_A_NEUTRAL():
	if frame == 8:
		create_hitbox(59,54,8, 0, 3, 90, 12, 'normal', Vector2(-2.5,5), 0, 1)
	if frame >= 20:
		return true
