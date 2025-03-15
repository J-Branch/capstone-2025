extends CharacterBody2D

var dash_duration = 10

@onready var states = $State

const RUNSPEED = 300
# DONT KNOW IF WE ARE DOING WALK SPEED YET
const DASHSPEED = 375
const AIR_DASHSPEED = 450
const GRAVITY = 1750
const JUMPFORCE = 450
const MAX_JUMPFORCE = 700
const DOUBLEJUMPFORCE = 1000
const MAXAIRSPEED = 300
const AIR_ACCEL = 25
const FALLSPEED = 70
const FALLINGSPEED = 900
const TRACTION = 40

var frame = 0
func updateframes(delta):
	frame += 1
	
func turn(direction):
	$Sprite.set_flip_h(direction)

func _frame():
	frame = 0

func _ready():
	pass

func _physics_process(delta: float) -> void:
	pass
