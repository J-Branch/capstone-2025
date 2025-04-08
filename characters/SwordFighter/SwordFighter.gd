extends CharacterBody2D

@export var id: int

var dash_duration = 25

@export var air_jump_max = 1
var air_jump_num = air_jump_max


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

const RUNSPEED = 300
# DONT KNOW IF WE ARE DOING WALK SPEED YET
const DASHSPEED = 375
const AIR_DASHSPEED = 450
const GRAVITY = 1750
const JUMPFORCE = 1000
const DOUBLEJUMPFORCE = 300
const MAXAIRSPEED = 300
const AIR_ACCEL = 25
const FALLSPEED = 10
const FALLINGSPEED = 500
const TRACTION = 40

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
	if frame == 8:
		create_hitbox(20,20,8, 0, 0, 0, 5, 'normal', Vector2(-16.5,-30.5), 0, 1)
	if frame == 13:
		create_hitbox(19,26.5,8, 0, 0, 0, 7, 'normal', Vector2(-1,-35.25), 0, 1)
	if frame == 20:
		create_hitbox(34,37,8, 0, 0, 0, 5, 'normal', Vector2(26,-6.5), 0, 1)
	if frame >= 25:
		return true
		
func B_SIDE():
	if frame == 16:
		create_hitbox(35.5,13,8, 0, 0, 0, 15, 'normal', Vector2(33.2,-2.5), 0, 1)
	if frame >= 32:
		return true

func B_NEUTRAL():
	if frame == 16:
		create_hitbox(27,31,8, 0, 0, 0, 8, 'normal', Vector2(26.5,-8.5), 0, 1)
	if frame >= 24:
		return true

# Air Attacks
func A_DOWN():
	if frame == 21:
		create_hitbox(11,17.5,8, 0, 0, 0, 8, 'normal', Vector2(0.5,21.2), 0, 1)
		create_hitbox(57,21.7,8, 0, 0, 0, 8, 'normal', Vector2(-4.5,38.1), 0, 1)
	if frame == 30:
		return true

func A_SIDE():
	if frame == 10:
		create_hitbox(32.75,25.4,8, 0, 0, 0, 4, 'normal', Vector2(8.62,-26.28), 0, 1)
		create_hitbox(20,31,8, 0, 0, 0, 4, 'normal', Vector2(34,-7.5), 0, 1)
	if frame == 14:
		create_hitbox(30,17,8, 0, 0, 0, 9, 'normal', Vector2(34,-0.5), 0, 1)
	if frame >= 24:
		return true

func A_NEUTRAL():
	if frame == 14:
		create_hitbox(59,24.5,8, 0, 0, 0, 7, 'normal', Vector2(3.5,-7.25), 0, 1)
	if frame >= 22:
		return true
	
# TRANSFORMED ATTACKS

# Ground Attacks
func T_B_DOWN():
	if frame == 20:
		create_hitbox(46.375,62,8, 0, 0, 0, 5, 'normal', Vector2(22.813,-18), 0, 1)
	if frame == 25:
		create_hitbox(46.375,25,8, 0, 0, 0, 2, 'normal', Vector2(31,8.5), 0, 1)
	if frame >= 28:
		return true
	
func T_B_SIDE():
	if frame == 10:
		create_hitbox(31.5,44.25,8, 0, 0, 0, 5, 'normal', Vector2(26,-4), 0, 1)
	if frame == 15:
		create_hitbox(34.75,61.125,8, 0, 0, 0, 4, 'normal', Vector2(32.625,-15.437), 0, 1)
	if frame == 19:
		create_hitbox(34.75,40,8, 0, 0, 0, 6, 'normal', Vector2(23,-14), 0, 1)
	if frame >= 26:
		return true

func T_B_NEUTRAL():
	if frame == 19:
		create_hitbox(31.5,44.25,8, 0, 0, 0, 9, 'normal', Vector2(34.25,-3.125), 0, 1)
	if frame >= 30:
		return true

# Air Attacks
func T_A_DOWN():
	if frame == 10:
		create_hitbox(50,25,8, 0, 0, 0, 6, 'normal', Vector2(2,13), 0, 1)
	if frame == 16:
		create_hitbox(73,42.25,8, 0, 0, 0, 6, 'normal', Vector2(3,32.125), 0, 1)
	if frame >= 22:
		return true

func T_A_SIDE():
	if frame == 12:
		create_hitbox(63.5,50.125,8, 0, 0, 0, 3, 'normal', Vector2(17.25,-18.062), 0, 1)
	if frame == 15:
		create_hitbox(33,34,8, 0, 0, 0, 9, 'normal', Vector2(35,-6), 0, 1)
	if frame >= 24:
		return true

func T_A_NEUTRAL():
	if frame == 11:
		create_hitbox(58,54,8, 0, 0, 0, 6, 'normal', Vector2(3,-21), 0, 1)
	if frame == 17:
		create_hitbox(59,35,8, 0, 0, 0, 6, 'normal', Vector2(3.5,-9), 0, 1)
	if frame >= 24:
		return true
