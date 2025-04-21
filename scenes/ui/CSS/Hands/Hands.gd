extends Node2D

var velocity: Vector2
var speed = 1000
var picking = false
@export var id: int

@onready var Detector = get_node("HandArea")
@onready var HandSprite = %HandSprite

enum States {
	POINT,
	GRAB,
	OPEN
}

var current_state = States.OPEN

func _ready():
	%Player_No.text = "p"+str(id)

func _physics_process(delta):
	self.name = ("Hand_%s" % id)
	match current_state:
		0: 
			HandSprite.play('HandPoint')
		1: 
			HandSprite.play('HandGrab')
		2: 
			HandSprite.play('HandOpen')

func _process(delta):
	var input := Vector2.ZERO
	input = Vector2(Input.get_action_strength("move_right%s" % id) - Input.get_action_strength("move_left%s" % id), Input.get_action_strength("move_down%s" % id) - Input.get_action_strength("jump%s" % id))
	global_position += (input * speed * delta)
	var dec = Detector.get_overlapping_areas()
	for b in dec:
		if b.name == "ButtonArea2D":
			current_state = States.POINT
	if Input.is_action_just_pressed("ui_select_%s" % id):
		for b in dec:
			if b.name == "Token Area" and (b.get_parent().id == id):
				if self.picking == false:
					current_state = States.GRAB
					b.get_parent().picked = true
					self.picking = true
				else:
					current_state = States.OPEN
					b.get_parent().picked = false
					b.get_parent().rest_point = b.get_parent().global_position
					b.get_parent().auto_snap()
					self.picking = false
			elif b.name == "ButtonArea2D":
				b.get_parent().emit_signal("pressed")
			elif b.name == "ReadyToFight":
				if current_state == States.POINT:
					pass # Transition to Stage Select Screen

func _on_HandArea_area_entered(area):
	if area.name == "ButtonArea2D":
		current_state = States.POINT
		var dec = Detector.get_overlapping_areas()
		for b in dec:
			if b.name == "Token Area" and (b.get_parent().id == id) and b.get_parent().picked == true:
				b.get_parent().picked == false
				b.get_parent().rest_point = b.get_parent().global_position
				b.get_parent().auto_snap()
				picking = false
	elif area.name == "ReadyToFight":
		current_state = States.POINT
		var dec = Detector.get_overlapping_areas()
		for b in dec:
			if b.name == "Token Area" and (b.get_parent().id == id) and b.get_parent().picked == true:
				b.get_parent().picked = false
				b.get_parent().rest_point = b.get_parent().global_position
				b.get_parent().auto_snap()
				picking = false

func _on_HandArea_area_exited(area):
	if area.name == "ButtonArea2D":
		current_state = States.OPEN
	elif area.name == "ReadyToFight":
		current_state = States.OPEN
