extends StateMachine


# @onready var id = get_parent().id


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_state('STAND')
	add_state('DASH')
	add_state('RUN')
	add_state('AIR')
	add_state('LANDING')
	add_state('GROUND_ATTACK')
	add_state('B_DOWN')
	add_state('B_SIDE')
	add_state('B_NEUTRAL')
	call_deferred("set_state", states.STAND)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass	
	
func state_logic(delta):
	parent.updateframes(delta)
	parent._physics_process(delta)

func get_transition(delta):
	parent.set_velocity(parent.velocity)
	parent.set_up_direction(Vector2.UP)
	parent.move_and_slide()
	parent.states.text = str(state)
	
	if Landing() == true:
		parent._frame()
		return states.LANDING

	if Falling() == true:
		return states.AIR

	if Input.is_action_pressed('attack') and Ground():
		parent.frame()
		return states.GROUND_ATTACK
	
	match state:
		states.STAND:
			parent.reset_jump()
			if Input.is_action_pressed("move_right"):
				parent.velocity.x = parent.RUNSPEED
				parent._frame()
				parent.turn(false)
				return states.RUN
			if Input.is_action_pressed("move_left"):
				parent.velocity.x = -parent.RUNSPEED
				parent._frame()
				parent.turn(true)
				return states.RUN
			if Input.is_action_pressed("jump"):
				parent.velocity.y = -parent.JUMPFORCE
				parent._frame()
				return states.AIR
			if Input.is_action_pressed("dash"):
				parent._frame()
				return states.DASH
				# Slows the player down if player is in a stand state and is moving right
			if parent.velocity.x > 0:
				parent.velocity.x -= parent.TRACTION
				parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
				# Slows the player down if the player is in a stand state and is moving left
			elif parent.velocity.x < 0:
				parent.velocity.x += parent.TRACTION
				parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
			return states.STAND
		states.AIR:
			if parent.velocity.y < parent.FALLINGSPEED:
				parent.velocity.y += parent.FALLSPEED
			if Input.is_action_pressed("dash"):
				parent._frame()
				return states.DASH
			# Slows the player down in the air if they are at max speed
			if abs(parent.velocity.x) >= abs(parent.MAXAIRSPEED):
				if parent.velocity.x > 0:
					if Input.is_action_pressed("move_left"):
						parent.velocity.x -= parent.AIR_ACCEL
				if parent.velocity.x < 0:
					if Input.is_action_pressed("move_right"):
						parent.velocity.x += parent.AIR_ACCEL
			# Speeds player up if he is below max speed
			elif abs(parent.velocity.x) < abs(parent.MAXAIRSPEED):
				if Input.is_action_pressed("move_left"):
					parent.velocity.x -= parent.AIR_ACCEL
				if Input.is_action_pressed("move_right"):
					parent.velocity.x += parent.AIR_ACCEL
			# If the player is not pressing anything 
			if not Input.is_action_pressed("move_left"):
				if not Input.is_action_pressed("move_right"):
					if parent.velocity.x < 0:
						parent.velocity.x += parent.AIR_ACCEL / 5
					elif parent.velocity.x > 0: 
						parent.velocity.x -= parent.AIR_ACCEL / 5
			# Code for double jump
			if Input.is_action_just_pressed("jump") and parent.air_jump_num > 0:
				parent.velocity.x = 0
				parent.velocity.y = -parent.DOUBLEJUMPFORCE
				parent.air_jump_num -= 1
				if Input.is_action_pressed("move_left"):
					parent.velocity.x = -parent.MAXAIRSPEED
				elif Input.is_action_pressed("move_right"):
					parent.velocity.x = parent.MAXAIRSPEED
				return states.AIR
			return states.AIR
		states.LANDING:
			if parent.frame <= parent.landing_frames + parent.lag_frames:
				if parent.frame == 1:
					pass
				# Slows down moving to right
				if parent.velocity.x > 0:
					parent.velocity.x = parent.velocity.x - parent.TRACTION / 2
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				# Slows down moving to left
				elif parent.velocity.x < 0:
					parent.velocity.x = parent.velocity.x + parent.TRACTION / 2
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			# Landing animation is finished
			else:
				parent._frame()
				parent.lag_frames = 0
				parent.reset_jump()
				return states.STAND
				
		states.DASH:
			# 5 frames to decide which direction to go
			if parent.frame < 5:
				if Input.is_action_pressed("move_left"):
					parent.turn(true)
					parent.velocity.x = -parent.DASHSPEED
				if Input.is_action_pressed("move_right"):
					parent.turn(false)
					parent.velocity.x = parent.DASHSPEED
			# When you are in the dash state you cannot go into any other state
			# You must wait for the dash state to finish
			if parent.frame >= parent.dash_duration-1:
				return states.STAND
		states.RUN:
			if Input.is_action_pressed("jump"):
				parent.velocity.y = -parent.JUMPFORCE
				parent._frame()
				return states.AIR
			if Input.is_action_pressed("dash"):
				parent._frame()
				return states.DASH
			if Input.is_action_pressed("move_right"):
				if parent.velocity.x > 0:
					parent._frame()
				parent.velocity.x = parent.RUNSPEED
				parent.turn(false)
				return states.RUN
			if Input.is_action_pressed("move_left"):
				if parent.velocity.x < 0:
					parent._frame() 
				parent.velocity.x = -parent.RUNSPEED
				parent.turn(true)
				return states.RUN
			# If I am not hitting anything else, state should return to stand
			else:
				return states.STAND
		states.GROUND_ATTACK:
			if Input.is_action_pressed('move_down'):
				parent.frame()
				return states.B_DOWN
			if Input.is_action_pressed('move_left'):
				parent.turn(true)
				parent.frame()
				return states.B_SIDE
			if Input.is_action_pressed('move_right'):
				parent.turn(false)
				parent.frame()
				return states.B_SIDE
			parent.frame()
			return states.B_NEUTRAL
		states.B_DOWN:
			if parent.frame == 0:
				parent.B_DOWN()
				pass
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x += parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x -= parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			if parent.B_DOWN(): # If animation finished
				parent.frame()
				return states.STAND
				
func Landing():
	if state_includes([states.AIR]):
		if (parent.GroundL.is_colliding()) or parent.GroundR.is_colliding():
			parent.frame = 0
			parent.velocity.y = 0
			return true
	"""
	if state_includes([states.AIR, states.DASH]):
		if (parent.GroundL.is_colliding()) and parent.velocity.y > 0:
			var collider = parent.GroundL.get_collider()
			parent.frame = 0
			if parent.velocity.y > 0:
				parent.velocity.y = 0
			return true
			
		elif (parent.GroundR.is_colliding()) and parent.velocity.y > 0:
			var collider2 = parent.GroundR.get_collider()
			parent.frame = 0
			if parent.velocity.y > 0:
				parent.velocity.y = 0
			return true
	"""

func Ground():
	if state_includes([states.STAND, states.RUN]):
		return true

func Falling():
	if state_includes([states.STAND, states.DASH, states.LANDING, states.RUN]):
		if not parent.GroundL.is_colliding() and not parent.GroundR.is_colliding():
				return true

func enter_state(new_state, old_state):
	match new_state:
		states.STAND:
			parent.play_animation('Idle')
			parent.states.text = str('STAND')
		states.RUN:
			parent.play_animation('Run')
			parent.states.text = str('RUN')
		states.AIR:
			parent.play_animation('Jump')
			parent.states.text = str('Air')
		states.DASH:
			parent.play_animation('Dash')
			parent.states.text = str('Dash')
		states.LANDING:
			parent.states.text = str('Landing')
		states.GROUND_ATTACK:
			parent.states.text = str('Ground_Attack')

func exit_state(old_state, new_state):
	pass 
	
func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false
