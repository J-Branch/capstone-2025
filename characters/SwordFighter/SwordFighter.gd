extends CharacterBody2D

var dash_duration = 25

var air_jump_max = 1
var air_jump_num = air_jump_max

@onready var states = $State

#Onready variables
@onready var GroundL = $'Raycasts/GroundL'
@onready var GroundR = $'Raycasts/GroundR'

@onready var anim = $Sprite/AnimationPlayer

# Air variables
var landing_frames = 0
var lag_frames = 0

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

var frame = 0
func updateframes(delta):
	frame += 1
	
func turn(direction):
	$Sprite.set_flip_h(direction)

func _frame():
	frame = 0

func play_animation(animation_name):
	anim.play(animation_name)

func reset_jump():
	air_jump_num = air_jump_max

func _ready():
	pass

func _physics_process(delta: float) -> void:
	pass
