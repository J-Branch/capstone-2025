extends Area2D

@onready var parent = get_parent()
@export var width = 300
@export var height = 400
@export var damage = 50
@export var angle = 90
@export var base_kb = 100
@export var kb_scaling = 2
@export var duration = 1500
@export var hitlag_modifier = 1
@export var type = 'normal'
@export var angle_flipper = 0
@onready var hitbox = get_node("Hitbox_Shape")
@onready var parentState = get_parent().selfState
var knockbackVal
var framez = 0
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
	update_extents()
	connect("body_entered", Callable(self, "Hitbox_Collide"))
	set_physics_process(true)

func update_extents():
	hitbox.shape.size = Vector2(width,height)

func _physics_process(delta):
	if framez < duration: 
		framez += floor(delta * 60)
	elif framez == duration:
		queue_free()
		return 
	if get_parent().selfState != parentState:
		Engine.time_scale = 1
		queue_free()
		return

func _ready() -> void:
	hitbox.shape = RectangleShape2D.new()
	set_physics_process(false)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func Hitbox_Collide(body):
	if !(body in player_list):
		player_list.append(body)
		var charstate
		charstate = body.get_node("StateMachine")
		weight = body.weight
		body.health -= damage
		knockbackVal = knockback(body.health, damage, weight, kb_scaling, base_kb, 1)
		charstate.state = charstate.states.HITFREEZE
		charstate.hitfreeze(hitlag(damage, hitlag_modifier), angle_flipperV2(Vector2(body.velocity.x, body.velocity.y), body.global_position))
		
		body.knockback = knockbackVal
		body.hitstun = getHitstun(knockbackVal/0.3)
		get_parent().connected = true 
		body._frame()
		
		Globals.hitstun(hitlag(damage, hitlag_modifier), hitlag(damage,hitlag_modifier) /60)
		get_parent().hit_pause_dur = duration - framez
		get_parent().temp_pos = get_parent().position
		get_parent().temp_vel = get_parent().velocity

@export var health = 0
@export var ratio = 1
@export var weight = 100

func hitlag(d, hit):
	damage = d
	hitlag_modifier = hit 
	return floor((((floor(d) * 0.65) + 6) * hit))

func knockback(h,d,w,ks,bk,r):
	health = h
	damage = d
	weight = w
	kb_scaling - ks
	base_kb = bk
	ratio = r
	# Math to determine knockback
	return (((((((damage/20)*(200/(weight+100))*1.4)+18)*(kb_scaling))+base_kb)*1))*.004 

const angleConversion = PI / 180

func getHorizontalDecay(angle): # The rate the a character slows down after knockback
	var decay = 0.051 * cos(angle * angleConversion)
	decay = round(decay * 100000) / 100000
	decay = decay * 1000
	return decay

func getVerticalDecay(angle):
	var decay = 0.051 * sin(angle * angleConversion)
	decay = round(decay * 100000) / 100000
	decay = decay * 1000
	return abs(decay)

func getHorizontalVelocity(knockback, angle): # Gets the horizontal knockback speed with total knockback and angle
		var initialVelocity = knockback * 30
		var horizontalAngle = cos(angle * angleConversion)
		var horizontalVelocity = initialVelocity * horizontalAngle 
		horizontalVelocity = round(horizontalVelocity * 100000) / 100000
		return horizontalVelocity
		
func getVerticalVelocity(knockback, angle):
		var initialVelocity = knockback * 30
		var verticalAngle = sin(angle * angleConversion)
		var verticalVelocity = initialVelocity * verticalAngle 
		verticalVelocity = round(verticalVelocity * 100000) / 100000
		return verticalVelocity

func angle_flipperV2(body_vel :Vector2, body_position :Vector2, hdecay = 0, vdecay = 0):
	var xangle 
	if get_parent().dir: # looking left
		xangle = (((body_position.angle_to_point(get_parent().global_position)) * 180)/PI) + 180
	else: # looking right
		xangle = (-(((body_position.angle_to_point(get_parent().global_position)) * 180)/PI)) + 180
	match angle_flipper:
		0:
			body_vel.x = (getHorizontalVelocity (knockbackVal, -angle))
			body_vel.y = (getVerticalVelocity (knockbackVal, -angle))
			hdecay = (getHorizontalDecay (-angle))
			vdecay = (getVerticalDecay (angle))
			return ([body_vel.x, body_vel.y, hdecay, vdecay])

func getHitstun(knockback):
	return floor(knockback * 0.4)
