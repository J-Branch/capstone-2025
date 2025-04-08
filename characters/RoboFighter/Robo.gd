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
	if frame >= 20:
		return true
		
func B_SIDE():
	if frame >= 24:
		return true

func B_NEUTRAL():
	if frame >= 20:
		return true

# Air Attacks
func A_DOWN():
	if frame == 20:
		return true

func A_SIDE():
	if frame >= 12:
		return true

func A_NEUTRAL():
	if frame >= 22:
		return true
	
# TRANSFORMED ATTACKS

# Ground Attacks
func T_B_DOWN():
	if frame >= 20:
		return true
	
func T_B_SIDE():
	if frame >= 16:
		return true

func T_B_NEUTRAL():
	if frame >= 16:
		return true

# Air Attacks
func T_A_DOWN():
	if frame >= 20:
		return true

func T_A_SIDE():
	if frame >= 16:
		return true

func T_A_NEUTRAL():
	if frame >= 20:
		return true
