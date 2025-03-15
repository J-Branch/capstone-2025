extends StateMachine

@onready var id = get_parent().id

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_state('STAND')
	add_state('JUMP')
	add_state('DASH')
	add_state('RUN')
	call_deferred("set_state", states.STAND)
	print("state set to stand")

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
	parent.velocity
	parent.states.text = str(state)
	match state:
		states.STAND:
			if Input.is_action_pressed("move_right"):
				parent.velocity.x = parent.RUNSPEED
				parent._frame()
				parent.turn(false)
				print("right stand")
				return states.RUN
			if Input.is_action_pressed("move_left"):
				parent.velocity.x = parent.RUNSPEED
				parent._frame()
				parent.turn(true)
				print("left stand")
				return states.RUN
				# Slows the player down if player is in a stand state and is moving right
			if parent.velocity.x > 0:
				parent.velocity.x -= parent.TRACTION
				parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
				# Slows the player down if the player is in a stand state and is moving left
			elif parent.velocity.x < 0:
				parent.velocity.x += parent.TRACTION
				parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
		states.JUMP:
			pass
		states.DASH:
			# When you are in the dash state you cannot go into any other state
			# You must wait for the dash state to finish
			if parent.frame >= parent.dash_duration-1:
				return states.Stand
		states.RUN:
			if Input.is_action_pressed("move_right"):
				if parent.velocity.x > 0:
					parent._frame() # Resets the frame var to 0
				parent.velocity.x = parent.RUNSPEED
				parent.turn(false)
				print("right run")
			if Input.is_action_pressed("move_left"):
				if parent.velocity.x < 0:
					parent._frame() # Resets the frame var to 0
				parent.velocity.x = -parent.RUNSPEED
				parent.turn(true)
				print("left run")
			# If I am not hitting anything else, state should return to stand
			else:
				return states.STAND

func enter_state(new_state, old_state):
	pass
	
func exit_state(old_state, new_state):
	pass 
	
func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false
