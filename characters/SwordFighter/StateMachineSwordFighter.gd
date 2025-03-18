extends StateMachine


##@onready var id = get_parent().id
var jump_number = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_state('STAND')
	add_state('DASH')
	add_state('RUN')
	add_state('AIR')
	add_state('LANDING')
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
	
	match state:
		states.STAND:
			if Input.is_action_pressed("move_right"):
				parent.velocity.x = parent.RUNSPEED
				parent._frame()
				parent.turn(false)
				return states.RUN
			if Input.is_action_pressed("move_left"):
				parent.velocity.x = parent.RUNSPEED
				parent._frame()
				parent.turn(true)
				return states.RUN
				# Slows the player down if player is in a stand state and is moving right
			if parent.velocity.x > 0:
				parent.velocity.x -= parent.TRACTION
				parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
				# Slows the player down if the player is in a stand state and is moving left
			elif parent.velocity.x < 0:
				parent.velocity.x += parent.TRACTION
				parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
			if Input.is_action_pressed("jump"):
				parent.velocity.y = -parent.JUMPFORCE
				parent._frame()
				return states.AIR
			else:
				return states.STAND
		states.AIR:
			if parent.velocity.y < parent.FALLINGSPEED:
				parent.velocity.y += parent.FALLSPEED
			# Slows the player down in the air if they are at max speed
			if abs(parent.velocity.x) >= abs(parent.MAXAIRSPEED):
				if parent.velocity.x > 0:
					if Input.is_action_pressed("move_left"):
						parent.velocity.x += -parent.AIR_ACCEL
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
				return states.STAND
				
		states.DASH:
			# When you are in the dash state you cannot go into any other state
			# You must wait for the dash state to finish
			if parent.frame >= parent.dash_duration-1:
				return states.Stand
		states.RUN:
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
			if Input.is_action_pressed("jump"):
				parent.velocity.y = -parent.JUMPFORCE
				parent._frame()
				return states.AIR
			# If I am not hitting anything else, state should return to stand
			else:
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


func Falling():
	if state_includes([states.STAND, states.DASH, states.LANDING, states.RUN]):
		if not parent.GroundL.is_colliding():
			if not parent.GroundR.is_colliding():
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
			parent.states.text = str('Jump')

func exit_state(old_state, new_state):
	pass 
	
func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false
