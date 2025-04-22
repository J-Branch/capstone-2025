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
var landing_frames = 5
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

# For healthbar
signal health_changed(current_health)

# For transformbar
var transform_mana_max = 1000
var transform_mana = 500
var transform_decay = 2.75
var transform_recovery = 1.25
signal transform_changed(current_transform)

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
	add_to_group("fighters")
	
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
	if frame == 6:
		create_hitbox(59,60.5,6, 45, 3, 80, 10, 'normal', Vector2(22,-16.75), 0, 1)
	if frame >= 16:
		return true
		
func B_SIDE():
	if frame == 5:
		create_hitbox(59,18,7, 30, 3, 85, 11, 'normal', Vector2(34.5,-3), 0, 1)
	if frame >= 16:
		return true

func B_NEUTRAL():
	if frame == 5:
		create_hitbox(34,37,4, 80, 3, 120, 7, 'normal', Vector2(28, -11), 0, 1)
	if frame >= 12:
		return true

# Air Attacks
func A_DOWN():
	if frame == 9:
		create_hitbox(58,48,6, 270, 3, 120, 12, 'normal', Vector2(-4.5,24), 0, 1)
	if frame == 21:
		return true

func A_SIDE():
	if frame == 2:
		create_hitbox(73.5,55.5,3, 330, 3, 80, 4, 'normal', Vector2(17.5,-14.5), 0, 1)
	if frame == 6:
		create_hitbox(37.75,31.75,3, 330, 3, 80, 10, 'normal', Vector2(35.375,-2.625), 0, 1)
	if frame >= 16:
		return true

func A_NEUTRAL():
	if frame == 7:
		create_hitbox(64,40.875,4, 0, 3, 130, 10, 'normal', Vector2(2.5,-9.437), 0, 1)
	if frame >= 17:
		return true
	
# TRANSFORMED ATTACKS

# Ground Attacks
func T_B_DOWN():
	if frame == 20:
		create_hitbox(46.375,62,4, 45, 3, 80, 5, 'normal', Vector2(22.813,-18), 0, 1)
	if frame == 25:
		create_hitbox(46.375,25,4, 45, 3, 120, 2, 'normal', Vector2(31,8.5), 0, 1)
	if frame >= 28:
		return true
	
func T_B_SIDE():
	if frame == 7:
		create_hitbox(64,64.938,5, 70, 3, 100, 10, 'normal', Vector2(18.5,-19.53), 0, 1)
	if frame >= 17:
		return true

func T_B_NEUTRAL():
	if frame == 7:
		create_hitbox(64,50.469,4, 20, 3, 115, 15, 'normal', Vector2(26,-7.266), 0, 1)
	if frame >= 22:
		return true

# Air Attacks
func T_A_DOWN():
	if frame == 8:
		create_hitbox(79,50.469,6, 270, 3, 110, 10, 'normal', Vector2(3.5,27), 0, 1)
	if frame >= 18:
		return true

func T_A_SIDE():
	if frame == 4:
		create_hitbox(69,50.469,3, 20, 3, 110, 6, 'normal', Vector2(18,-18), 0, 1)
	if frame == 10:
		create_hitbox(48,21.234,3, 20, 3, 110, 6, 'normal', Vector2(28.5,-3.383), 0, 1)
	if frame >= 16:
		return true

func T_A_NEUTRAL():
	if frame == 5:
		create_hitbox(61.5,57.617,6, 60, 3, 120, 14, 'normal', Vector2(3.75,-18.69), 0, 1)
	if frame >= 19:
		return true
